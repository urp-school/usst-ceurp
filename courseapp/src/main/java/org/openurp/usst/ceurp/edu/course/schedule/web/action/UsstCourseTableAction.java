/*
 * OpenURP, Agile University Resource Planning Solution.
 *
 * Copyright (c) 2005, The OpenURP Software.
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
import org.beangle.commons.lang.time.WeekTime;
import org.openurp.edu.base.model.Semester;
import org.openurp.edu.base.model.Squad;
import org.openurp.edu.base.model.TimeSetting;
import org.openurp.edu.course.model.Session;
import org.openurp.edu.course.schedule.helper.DigestorHelper;
import org.openurp.edu.course.schedule.web.action.CourseTableAction;

/**
 * @author zhouqi 2018年9月27日
 *
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

    Map<String, String> sessionClassMap = CollectUtils.newHashMap();

    // FIXME 2018-09-21 zhouqi 不能在for循环中查询
    for (Squad squad : squades) {
      List<Session> courseActivities = teachResourceService.getSquadActivities(squad, null, semester);
      if (CollectionUtils.isNotEmpty(courseActivities)) {
        realSquades.add(squad);
        Collections.sort(courseActivities, new Comparator<Session>() {

          @Override
          public int compare(Session s1, Session s2) {
            int c_date = s1.getBeginAt().compareTo(s2.getBeginAt());

            if (0 == c_date) {
              return s1.getTime().getBeginAt().compareTo(s2.getTime().getBeginAt());
            }

            return c_date;
          }
        });

        int max = 1;
        String his = null;
        Map<String, List<Session>> sessionMap = CollectUtils.newHashMap();
        for (Session session : courseActivities) {
          sessionClassMap.put(session.getId().toString(), session.getClass().getName() + "@" + Integer.toHexString(session.hashCode()));
          String curr = session.getTime().getWeekday().getName() + "|" + session.getTime().getBeginAt();
          if (StringUtils.isBlank(his) || !StringUtils.equals(curr, his)) {
            max = 1;
          } else {
            max++;
          }
          his = curr;

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
        dataMap.put("max", max);
        courseTableMap.put(squad.getId().toString(), dataMap);
      }
    }

    weekTimes = Arrays.asList(weekTimeMap.values().toArray(new WeekTime[0]));
    Collections.sort(weekTimes, new Comparator<WeekTime>() {

      @Override
      public int compare(WeekTime wt1, WeekTime wt2) {
        int result = wt1.getFirstDay().compareTo(wt2.getFirstDay());
        if (0 == result) {
          return wt1.getBeginAt().getValue() - wt2.getBeginAt().getValue();
        }
        return result;
      };
    });

    Collections.sort(realSquades, new MultiPropertyComparator("department.code,major.code,code"));
    put("squades", realSquades);
    put("weekTimes", weekTimes);
    TimeSetting timeSetting = timeSettingService.getClosestTimeSetting(getProject(), semester, null);
    put("timeSetting", timeSetting);
    put("courseTableMap", courseTableMap);
    put("sessionClassMap", sessionClassMap);

    put("semester", semester);
    put("digestor", new DigestorHelper(getTextResource(), timeSetting));
    return forward();
  }
}
