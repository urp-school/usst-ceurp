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

import java.time.LocalDate;
import java.util.*;

import org.apache.commons.collections.CollectionUtils;
import org.beangle.commons.bean.comparators.MultiPropertyComparator;
import org.beangle.commons.collection.CollectUtils;
import org.beangle.commons.dao.query.builder.Condition;
import org.beangle.commons.dao.query.builder.OqlBuilder;
import org.beangle.orm.hibernate.udt.WeekTime;
import org.openurp.base.edu.model.Semester;
import org.openurp.base.edu.model.Squad;
import org.openurp.base.edu.model.Student;
import org.openurp.base.edu.model.StudentState;
import org.openurp.edu.clazz.model.Clazz;
import org.openurp.edu.clazz.model.Session;
import org.openurp.edu.schedule.helper.DigestorHelper;
import org.openurp.edu.schedule.web.action.CourseTableAction;
import org.openurp.edu.clazz.service.CourseLimitUtils;
import org.openurp.edu.clazz.util.ScheduleDigestor;

import static java.time.temporal.ChronoUnit.DAYS;

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
    List<Squad> squades = entityDao.get(Squad.class, getLongIds("adminClass"));
    List<Squad> realSquades = CollectUtils.newArrayList();

    Map<String, WeekTime> weekTimeMap = CollectUtils.newHashMap();
    List<WeekTime> weekTimes = CollectUtils.newArrayList();
    Map<Squad,Integer> squadStdCounts=CollectUtils.newHashMap();
    for (Squad squad : squades) {
      squadStdCounts.put(squad,getInSchoolStudents(squad,semester).size());
      List<Session> courseActivities = ScheduleDigestor.merge(semester, teachResourceService.getSquadActivities(squad, null, semester), true, true);
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
    put("squadStdCounts",squadStdCounts);
    put("semester", semester);
    put("digestor", new DigestorHelper(getTextResource(), null));
    return forward();
  }


  private Set<Student> getInSchoolStudents(Squad squad, Semester semester) {
    LocalDate beginOn = semester.getBeginOn().toLocalDate();
    LocalDate endOn = semester.getEndOn().toLocalDate();
    int days = (int) DAYS.between(beginOn, endOn);
    days = days * 2 / 3;

    Set<Student> stds = CollectUtils.newHashSet();
    for (StudentState ss : squad.getStdStates()) {
      if (ss.isInschool()) {
        LocalDate sBeginOn = ss.getBeginOn().toLocalDate();
        LocalDate sEndOn = ss.getEndOn().toLocalDate();
        if (sBeginOn.isBefore(endOn) && beginOn.isBefore(sEndOn)) {
          LocalDate minEndOn = endOn;
          if (sEndOn.isBefore(minEndOn)) {
            minEndOn = sEndOn;
          }
          LocalDate maxBeginOn = beginOn;
          if (sBeginOn.isAfter(maxBeginOn)) {
            maxBeginOn = sBeginOn;
          }
          if (DAYS.between(maxBeginOn, minEndOn) >= days) {
            stds.add(ss.getStd());
          }
        }
      }
    }
    return stds;
  }
}
