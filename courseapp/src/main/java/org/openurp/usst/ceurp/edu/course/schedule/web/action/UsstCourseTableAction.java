/*
 * OpenURP, Agile University Resource Planning Solution.
 *
 * Copyright © 2014, The OpenURP Software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful.
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.openurp.usst.ceurp.edu.course.schedule.web.action;

import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.beangle.commons.bean.comparators.MultiPropertyComparator;
import org.beangle.commons.collection.CollectUtils;
import org.beangle.commons.dao.query.builder.Condition;
import org.beangle.commons.dao.query.builder.OqlBuilder;
import org.beangle.commons.lang.time.WeekTime;
import org.openurp.edu.base.model.Semester;
import org.openurp.edu.base.model.Squad;
import org.openurp.edu.base.model.TimeSetting;
import org.openurp.edu.course.model.Clazz;
import org.openurp.edu.course.model.Session;
import org.openurp.edu.course.schedule.helper.DigestorHelper;
import org.openurp.edu.course.schedule.web.action.CourseTableAction;
import org.openurp.edu.course.service.CourseLimitUtils;

/**
 * @author zhouqi 2018年9月27日
 */
public class UsstCourseTableAction extends CourseTableAction {

  /**
   * 大课表(班级)
   */
  public String courseTableOfClass() {
    Semester semester = semesterService.getSemester(getIntId("semester"));
    Map<String, Object> courseTableMap = CollectUtils.newHashMap();
    List<Squad> squades = entityDao.get(Squad.class, getIntIds("adminClass"));
    List<Squad> realSquades = CollectUtils.newArrayList();

    Map<String, WeekTime> weekTimeMap = CollectUtils.newHashMap();
    List<WeekTime> weekTimes = CollectUtils.newArrayList();

    for (Squad squad : squades) {
      List<Session> courseActivities = teachResourceService.getSquadActivities(squad, null, semester);
      if (CollectionUtils.isNotEmpty(courseActivities)) {
        realSquades.add(squad);
        Collections.sort(courseActivities, new Comparator<Session>() {

          @Override
          public int compare(Session s1, Session s2) {
            int c_date = s1.getBeginAt().compareTo(s2.getBeginAt());

            if (0 == c_date) { return s1.getTime().getBeginAt().compareTo(s2.getTime().getBeginAt()); }

            return c_date;
          }
        });

        Map<String, List<Session>> sessionMap = CollectUtils.newHashMap();
        for (Session session : courseActivities) {
          String curr = session.getTime().getWeekday().getName() + "|" + session.getTime().getBeginAt();

          if (!weekTimeMap.containsKey(curr)) {
            weekTimeMap.put(curr, session.getTime());
          }

          if (!sessionMap.containsKey(curr)) {
            sessionMap.put(curr, CollectUtils.newArrayList());
          }
          sessionMap.get(curr).add(session);
        }
        Map<String, Object> dataMap = CollectUtils.newHashMap();
        dataMap.put("sessionMap", sessionMap);
        int max = 0;
        for (Map.Entry<String, List<Session>> e : sessionMap.entrySet()) {
          if (e.getValue().size() > max) {
            max = e.getValue().size();
          }
        }
        dataMap.put("max", max);

        OqlBuilder<Clazz> clazzQuery = OqlBuilder.from(Clazz.class, "clazz");
        clazzQuery.where("clazz.project = :project", getProject());
        clazzQuery.where("clazz.semester =:semester", semester);
        Condition con = CourseLimitUtils.build(squad, "lgi");
        List<?> params = con.getParams();
        clazzQuery.where(
            "exists(from clazz.enrollment.restrictions lg join lg.items as lgi where (lgi.inclusive=true  and "
                + con.getContent() + "))",
            params.get(0), params.get(1), params.get(2));
        clazzQuery.where("size(clazz.schedule.sessions)=0");
        List<Clazz> noScheduled = entityDao.search(clazzQuery);
        dataMap.put("noScheduled", noScheduled);
        courseTableMap.put(squad.getId().toString(), dataMap);
      }
    }

    weekTimes = Arrays.asList(weekTimeMap.values().toArray(new WeekTime[0]));
    Collections.sort(weekTimes, new Comparator<WeekTime>() {

      @Override
      public int compare(WeekTime wt1, WeekTime wt2) {
        int result = wt1.getWeekday().compareTo(wt2.getWeekday());
        if (0 == result) { return wt1.getBeginAt().getValue() - wt2.getBeginAt().getValue(); }
        return result;
      };
    });

    Collections.sort(realSquades, new MultiPropertyComparator("department.code,major.code,code"));
    put("squades", realSquades);
    put("weekTimes", weekTimes);
    put("courseTableMap", courseTableMap);

    put("semester", semester);
    put("digestor", new DigestorHelper(getTextResource(), null));
    return forward();
  }
}
