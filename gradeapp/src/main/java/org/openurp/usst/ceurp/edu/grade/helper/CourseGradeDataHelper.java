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
/**
 *
 */
package org.openurp.usst.ceurp.edu.grade.helper;

import java.util.Calendar;
import java.util.List;
import java.util.Map;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.beangle.commons.collection.CollectUtils;
import org.openurp.base.edu.model.Semester;
import org.openurp.edu.grade.course.model.CourseGrade;

/**
 * @author zhouqi 2018年9月14日
 *
 */
public class CourseGradeDataHelper {

  /**
   * 将成绩按春秋两学期为一组的分组
   *
   * @param courseGrades
   * @return
   */
  public Map<String, Object> courseGradeBy2Semester(List<CourseGrade> courseGrades) {
    Map<String, Object> resultMap = CollectUtils.newHashMap();

    if (CollectionUtils.isNotEmpty(courseGrades)) {
      Map<Integer, Semester> semestersByYearMap = CollectUtils.newHashMap();
      Map<String, Map<String, List<CourseGrade>>> courseGradeMap = CollectUtils.newHashMap();

      for (CourseGrade courseGrade : courseGrades) {
        Calendar beginOn = DateUtils.toCalendar(courseGrade.getSemester().getBeginOn());
        semestersByYearMap.put(beginOn.get(Calendar.YEAR), courseGrade.getSemester());

        String year = courseGrade.getSemester().getSchoolYear();
        if (!courseGradeMap.containsKey(year)) {
          courseGradeMap.put(year, CollectUtils.newHashMap());
        }
        // 有成绩的，一定占用一个学年学期，就不存在该年里没有成绩了
        String whichHalf = beginOn.get(Calendar.MONTH) < Calendar.JULY ? "firstHalf" : "secondHalf";
        if (!courseGradeMap.get(year).containsKey(whichHalf)) {
          courseGradeMap.get(year).put(whichHalf, CollectUtils.newArrayList());
        }
        courseGradeMap.get(year).get(whichHalf).add(courseGrade);
      }

      resultMap.put("semesters", semestersByYearMap.values());
      resultMap.putAll(courseGradeMap);
    }

    return resultMap;
  }
}
