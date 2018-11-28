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

import org.beangle.commons.collection.CollectUtils;
import org.beangle.commons.collection.Order;
import org.beangle.commons.dao.EntityDao;
import org.beangle.commons.dao.query.builder.OqlBuilder;
import org.openurp.edu.base.model.Semester;
import org.openurp.edu.base.model.Student;
import org.openurp.edu.grade.transcript.service.TranscriptDataProvider;

/**
 * @author zhouqi 2018年9月7日
 *
 */
public class TranscriptNextSemesterProvider implements TranscriptDataProvider {

  private EntityDao entityDao;

  @SuppressWarnings("rawtypes")
  @Override
  public Object getDatas(List<Student> stds, Map<String, String> options) {
    Map semestersMap = CollectUtils.newHashMap();

    List<Semester> semesters = entityDao.search(OqlBuilder.from(Semester.class, "semester").orderBy(
        Order.parse("semester.beginOn")));

    for (int i = 0; i < semesters.size(); i++) {
      Map<String, Semester> semesterMap = CollectUtils.newHashMap();
      semesterMap.put("next", i + 1 < semesters.size() ? semesters.get(i + 1) : null);
      semestersMap.put(semesters.get(i).getId().toString(), semesterMap);
    }
    return semestersMap;
  }

  @Override
  public String getDataName() {
    return "semesterMap";
  }

  public void setEntityDao(EntityDao entityDao) {
    this.entityDao = entityDao;
  }
}
