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
package org.openurp.usst.ceurp.edu.grade.transcript.service.impl;

import java.util.List;
import java.util.Map;

import org.openurp.base.edu.model.Student;
import org.openurp.edu.grade.transcript.service.TranscriptDataProvider;
import org.openurp.usst.ceurp.edu.grade.helper.CourseGradeDataHelper;

/**
 * @author zhouqi 2018年9月14日
 *
 */
public class TranscriptSemesterGroupProvider implements TranscriptDataProvider {

  private CourseGradeDataHelper courseGradeDataHelper;

  @Override
  public Object getDatas(List<Student> stds, Map<String, String> options) {
    return courseGradeDataHelper;
  }

  @Override
  public String getDataName() {
    return "semesterGroup";
  }

  public void setCourseGradeDataHelper(CourseGradeDataHelper courseGradeDataHelper) {
    this.courseGradeDataHelper = courseGradeDataHelper;
  }
}
