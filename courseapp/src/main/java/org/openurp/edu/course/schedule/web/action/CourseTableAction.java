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
package org.openurp.edu.course.schedule.web.action;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.collections.Transformer;
import org.apache.commons.lang3.ArrayUtils;
import org.beangle.commons.bean.comparators.MultiPropertyComparator;
import org.beangle.commons.bean.comparators.PropertyComparator;
import org.beangle.commons.collection.CollectUtils;
import org.beangle.commons.collection.Order;
import org.beangle.commons.conversion.impl.DefaultConversion;
import org.beangle.commons.dao.query.builder.Condition;
import org.beangle.commons.dao.query.builder.OqlBuilder;
import org.beangle.commons.entity.Entity;
import org.beangle.commons.entity.metadata.Model;
import org.beangle.commons.lang.Strings;
import org.beangle.commons.lang.time.WeekDay;
import org.beangle.commons.lang.time.WeekStates;
import org.beangle.commons.lang.time.WeekTime;
import org.beangle.commons.lang.tuple.Pair;
import org.beangle.struts2.helper.Params;
import org.beangle.struts2.helper.QueryHelper;
import org.openurp.base.model.Building;
import org.openurp.base.model.Campus;
import org.openurp.base.model.Semester;
import org.openurp.base.time.NumberSequence;
import org.openurp.base.time.WeekTimeBuilder;
import org.openurp.code.edu.model.ClassroomType;
import org.openurp.code.person.model.Gender;
import org.openurp.edu.base.code.model.CourseHourType;
import org.openurp.edu.base.code.model.CourseType;
import org.openurp.edu.base.code.model.EduSpan;
import org.openurp.edu.base.code.model.StdType;
import org.openurp.edu.base.model.Classroom;
import org.openurp.edu.base.model.Course;
import org.openurp.edu.base.model.Project;
import org.openurp.edu.base.model.Squad;
import org.openurp.edu.base.model.Student;
import org.openurp.edu.base.model.Teacher;
import org.openurp.edu.base.model.Textbook;
import org.openurp.edu.base.service.StudentService;
import org.openurp.edu.base.service.TeachResourceService;
import org.openurp.edu.course.model.Clazz;
import org.openurp.edu.course.model.CourseTaker;
import org.openurp.edu.course.model.Material;
import org.openurp.edu.course.model.RestrictionMeta.Operator;
import org.openurp.edu.course.model.Session;
import org.openurp.edu.course.schedule.domain.CourseTableSetting;
import org.openurp.edu.course.schedule.util.CourseTable;
import org.openurp.edu.course.schedule.util.MultiCourseTable;
import org.openurp.edu.course.service.ClazzFilterStrategy;
import org.openurp.edu.course.service.ClazzFilterStrategyFactory;
import org.openurp.edu.course.service.ClazzService;
import org.openurp.edu.course.service.CourseLimitUtils;
import org.openurp.edu.course.service.CourseTableStyle;
import org.openurp.edu.course.util.ScheduleDigestor;
import org.openurp.edu.eams.web.helper.BaseInfoSearchHelper;
import org.openurp.edu.eams.web.helper.StdSearchHelper;
import org.openurp.edu.program.plan.model.CourseGroup;
import org.openurp.edu.program.plan.model.MajorPlan;
import org.openurp.edu.program.plan.service.MajorPlanService;
import org.openurp.edu.web.action.SemesterSupportAction;

/**
 * 课程表显示界面相应类. 可以显示 <br>
 * 1)管理人员对班级、学生和教师的课程复杂查询管理界面<br>
 * 2)学生对自己个人课表和班级（包括双专业班级）的课表<br>
 * 3)教师对自己个人课表的浏览.<br>
 * <p>
 * 所有的课表均用一个课表显示界面.上部为课表，下部为教学任务列表.
 * </p>
 */
public class CourseTableAction extends SemesterSupportAction {

  protected ClazzFilterStrategyFactory clazzFilterStrategyFactory;

  protected ClazzService clazzService;

  protected BaseInfoSearchHelper baseInfoSearchHelper;

  protected StudentService studentService;

  protected TeachResourceService teachResourceService;

  protected MajorPlanService majorPlanService;

  protected StdSearchHelper stdSearchHelper;

  protected Map<Squad, Map<CourseType, Float>> squadCourseGroups = CollectUtils.newHashMap();

  protected Map<Squad, Map<CourseType, Set<Clazz>>> squadClazzGroups = CollectUtils.newHashMap();

  /**
   * 管理人员查看课表入口（主界面）
   *
   * @return @
   */
  @Override
  public String index() {
    put("stdTypeList", getStdTypes());
    put("departmentList", getColleges());
    Semester semester = getSemester();
    put("classroomConfigTypeList", codeService.getCodes(ClassroomType.class));
    addBaseInfo("campusList", Campus.class);
    addBaseInfo("buildings", Building.class);
    Project project = getProject();
    put("campuses", project.getCampuses());
    put("teacherDeparts", projectContext.getDeparts());
    put("teachDeparts",
        clazzService.teachDepartsOfSemester(CollectUtils.newArrayList(project), getDeparts(), getSemester()));
    put("courseTableType", get("courseTableType"));
    put("genders", codeService.getCodes(Gender.class));
    put("maxWeek", semester.getWeeks());
    return forward();
  }

  public String courseTaker() {
    Long clazzId = getLongId("clazz");
    Integer squadId = getIntId("squad");
    if (null == clazzId) {
      return forwardError("error.model.id.needed");
    }
    Clazz clazz = entityDao.get(Clazz.class, clazzId);
    put("clazz", clazz);
    Set<CourseTaker> courseTakers = clazz.getEnrollment().getCourseTakers();
    List<CourseTaker> targetCourseTakers = CollectUtils.newArrayList();
    if (null != squadId) {
      for (CourseTaker courseTaker : courseTakers) {
        if (courseTaker.getStd().getSquad().getId().equals(squadId)) {
          targetCourseTakers.add(courseTaker);
        }
      }
      put("courseTakers", targetCourseTakers);
    } else {
      put("courseTakers", courseTakers);
    }
    return forward();
  }

  /**
   * 获得某一教学任务的课程安排
   *
   * @return @
   */
  public String taskTable() {
    Long clazzId = getLongId("clazz");
    Clazz clazz = entityDao.get(Clazz.class, clazzId);
    put("startWeek", new Integer(1));
    put("endWeek", new Integer(clazz.getSemester().getWeeks()));
    put("weekList", WeekTimeBuilder.getWeekDays(clazz.getSemester()));
    put("activityList", clazz.getSchedule().getSessions());
    put("clazz", clazz);
    put("semester", clazz.getSemester());
    put("timeSetting", timeSettingService.getClosestTimeSetting(getProject(), clazz.getSemester(), null));
    put("tableStyle", CourseTableStyle.getStyle((String) getConfig().get(CourseTableStyle.STYLE_KEY)));
    return forward();
  }

  /**
   * 大课表(班级)
   */
  public String courseTableOfClass() {
    Integer[] adminClassIds = Strings.splitToInt(get("adminClassIds"));
    Integer semesterId = getInt("semester.id");
    Semester semester = semesterService.getSemester(semesterId);
    Map<String, Collection<Session>> courseTableMap = CollectUtils.newHashMap();
    List<Squad> squades = CollectUtils.newArrayList();
    if (ArrayUtils.isNotEmpty(adminClassIds)) {
      squades = entityDao.get(Squad.class, adminClassIds);
    }
    List<Squad> squadForNoMajors = CollectUtils.newArrayList();

    List<WeekTime> weekTimes = CollectUtils.newArrayList();

    // FIXME 2018-09-21 zhouqi 不能在for循环中查询
    for (Squad squad : squades) {
      List<Session> courseActivities = teachResourceService.getSquadActivities(squad, null, semester);
      courseTableMap.put(squad.getId().toString(), courseActivities);
      putActivityId2ArrangeWeek(semester, courseActivities);
      if (null == squad.getMajor()) {
        squadForNoMajors.add(squad);
      }
      for (Session session : courseActivities) {
        if (!weekTimes.contains(session.getTime())) {
          weekTimes.add(session.getTime());
        }
      }
    }

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

    put("timeSetting", timeSettingService.getClosestTimeSetting(getProject(), semester, null));
    put("weekTimes", weekTimes);
    put("semester", semester);
    put("courseTableMap", courseTableMap);
    squades.removeAll(squadForNoMajors);
    Collections.sort(squades, new MultiPropertyComparator("department.code,major.code,code"));
    squades.addAll(squades.size(), squadForNoMajors);
    put("adminClasses", squades);
    return forward();
  }

  /**
   * 大课表(教师)
   */
  public String courseTableOfTeacher() {
    Long[] teacherIds = Strings.splitToLong(get("teacherIds"));
    Integer semesterId = getInt("semester.id");
    Semester semester = semesterService.getSemester(semesterId);
    Map<String, Collection<Session>> courseTables = CollectUtils.newHashMap();
    List<Teacher> teachers = CollectUtils.newArrayList();
    if (ArrayUtils.isNotEmpty(teacherIds)) {
      teachers = entityDao.get(Teacher.class, teacherIds);
    }

    WeekTime time = new WeekTime();
    for (Teacher teacher : teachers) {
      List<Session> courseActivities = teachResourceService.getTeacherActivities(teacher, time, semester);
      courseTables.put(teacher.getId().toString(), courseActivities);

      putActivityId2ArrangeWeek(semester, courseActivities);
    }
    put("timeSetting", timeSettingService.getClosestTimeSetting(getProject(), semester, null));
    put("semester", semester);
    put("courseTables", courseTables);
    Collections.sort(teachers, new PropertyComparator("code"));
    put("teachers", teachers);
    put("weeks", WeekTimeBuilder.getWeekDays(semester));

    return forward();
  }

  /**
   * 大课表(教室)
   */
  public String courseTableOfClassroom() {
    Integer[] roomIds = Strings.splitToInt(get("roomIds"));
    Integer semesterId = getInt("semester.id");
    Semester semester = semesterService.getSemester(semesterId);
    Map<String, Collection<Session>> courseTables = CollectUtils.newHashMap();
    List<Classroom> classrooms = CollectUtils.newArrayList();
    if (ArrayUtils.isNotEmpty(roomIds)) {
      classrooms = entityDao.get(Classroom.class, roomIds);
    }
    Integer w = getInt("week");
    if (null != w) {
      // TODO
    }
    WeekTime time = new WeekTime();
    for (Classroom classroom : classrooms) {
      List<Session> courseActivities = teachResourceService.getRoomActivities(classroom, time, semester);
      courseTables.put(classroom.getId().toString(), courseActivities);
      putActivityId2ArrangeWeek(semester, courseActivities);
    }
    put("timeSetting", timeSettingService.getClosestTimeSetting(getProject(), semester, null));
    put("semester", semester);
    put("courseTables", courseTables);
    Collections.sort(classrooms, new PropertyComparator("code"));
    put("classrooms", classrooms);
    put("weeks", WeekTimeBuilder.getWeekDays(semester));
    return forward();
  }

  private void putActivityId2ArrangeWeek(Semester semester, Collection<Session> courseActivities) {
    Map<Long, String> activityId2ArrangeWeek = CollectUtils.newHashMap();
    ScheduleDigestor digestor = ScheduleDigestor.getInstance();
    for (Session courseActivity : courseActivities) {
      activityId2ArrangeWeek.put(
          courseActivity.getId(),
          digestor.digest(getTextResource(),
              timeSettingService.getClosestTimeSetting(getProject(), semester, null),
              Collections.singleton(courseActivity), ScheduleDigestor.weeks));
    }
    put("activityId2ArrangeWeek", activityId2ArrangeWeek);
  }

  protected OqlBuilder<Student> buildStdQuery() {
    OqlBuilder<Student> query = OqlBuilder.from(Student.class, "std");
    populateConditions(query);
    Boolean stdActive = getBoolean("stdActive");
    if (null != stdActive) {
      if (Boolean.TRUE.equals(stdActive)) {
        query.where("std.beginOn <= :now and std.endOn >= :now and std.registed = true", new Date());
      } else {
        query.where("std.beginOn > :now or std.endOn < :now or std.registed=false", new Date());
      }
    }
    List<EduSpan> spans = getSpans();
    if (!spans.isEmpty()) {
      query.where("std.span in (:spans)", spans);
    }
    // List<Department> departments = getDeparts();
    // if (!departments.isEmpty()) {
    // query.where("std.state.department in (:departments)", departments);
    // }
    query.where("std.project = :project", getProject());
    List<StdType> stdTypes = getStdTypes();
    if (!stdTypes.isEmpty()) {
      query.where("std.stdType in (:stdTypes)", stdTypes);
    }
    query.limit(QueryHelper.getPageLimit());
    query.orderBy(Order.parse(Params.get("orderBy")));
    String squadName = Params.get("squadName");
    if (Strings.isNotEmpty(Strings.trim(squadName))) {
      query.where(new Condition("std.state.squad.name like :squadName", squadName));
    }
    return query;
  }

  /**
   * 查询教学资源对象（教师、学生、班级,教室）
   * <p>
   * courseTableType为页面回传的对象类别参数<br>
   * 1)class 班级 2)std 学生 3)teacher 教师 4)room
   * </p>
   *
   * @return @
   */
  public String search() {
    String kind = get("courseTableType");
    if (Strings.isEmpty(kind)) {
      return forwardError("error.courseTable.unknown");
    }
    Semester semester = semesterService.getSemester(getInt("semester.id"));
    put("semester", semester);
    Integer week = getInt("week");
    Project project = getProject();
    if (CourseTable.CLASS.equals(kind)) {
      OqlBuilder<Squad> q = baseInfoSearchHelper.buildSquadQuery(project);
      put("squades", entityDao.search(q));
      return forward("adminClassList");
    } else if (CourseTable.STD.equals(kind)) {
      put("students", entityDao.search(buildStdQuery().where("std.project = :project", project)));
      return forward("stdList");
    } else if (CourseTable.ROOM.equals(kind)) {
      OqlBuilder<Classroom> query = baseInfoSearchHelper.buildClassroomQuery(project);
      if (null != week) {
        Pair<String, List<Object>> segs = buildActivityQuery(semester, week);
        Condition c = new Condition("exists(from " + Session.class.getName()
            + " ca join ca.rooms r where r.id = classroom.id and ca.clazz.semester.id=" + semester.getId()
            + " and (" + segs._1 + "))");
        c.params(segs._2);
        query.where(c);
      }
      put("classrooms", entityDao.search(query));
      return forward("classroomList");
    } else if (CourseTable.TEACHER.equals(kind)) {
      OqlBuilder<Teacher> builder = baseInfoSearchHelper.buildTeacherQuery(project);
      if (null != week) {
        Pair<String, List<Object>> segs = buildActivityQuery(semester, week);
        Condition c = new Condition("exists(from " + Session.class.getName()
            + " ca join ca.teachers t where t.id = teacher.id and ca.clazz.semester.id=" + semester.getId()
            + " and (" + segs._1 + "))");
        c.params(segs._2);
        builder.where(c);
      }
      List<Teacher> teachers = entityDao.search(builder);
      put("teachers", teachers);
      return forward("teacherList");
    } else {
      put("weeks", WeekTimeBuilder.getWeekDays(semester));
      put("timeSetting", timeSettingService.getClosestTimeSetting(getProject(), getSemester(), null));
      put("tableStyle", CourseTableStyle.getStyle((String) getConfig().get(CourseTableStyle.STYLE_KEY)));
      return forward("clazzList");
    }
  }

  private Pair<String, List<Object>> buildActivityQuery(Semester semester, int week) {
    WeekTimeBuilder weekTimeBuilder = WeekTimeBuilder.on(semester);
    Map<Long, List<Date>> dates = new java.util.HashMap<Long, List<Date>>();
    for (WeekDay d : WeekDay.All) {
      List<WeekTime> times = weekTimeBuilder.build(d, new int[] { week });
      for (WeekTime t : times) {
        List<Date> dateList = dates.get(t.getWeekstate().value);
        if (null == dateList) {
          dateList = new ArrayList<Date>();
          dates.put(t.getWeekstate().value, dateList);
        }
        dateList.add(t.getStartOn());
      }
    }
    StringBuilder sb = new StringBuilder();
    int i = 0;
    List<Object> params = new ArrayList<Object>();
    for (Map.Entry<Long, List<Date>> entry : dates.entrySet()) {
      if (sb.length() > 0)
        sb.append(" or ");
      sb.append("(bitand(ca.time.weekstate,:weekstate" + i + ")>0 and ca.time.startOn in(:startOn" + i + "))");
      params.add(entry.getKey());
      params.add(entry.getValue());
      i += 1;
    }
    return Pair.of(sb.toString(), params);
  }

  /**
   * 课程表
   *
   * @return @
   */
  @SuppressWarnings({ "unchecked", "rawtypes" })
  public String courseTable() {
    // 查找课表设置参数
    Semester semester = getSemester();
    if (semester == null) {
      return forwardError("error.semester.id.notExists");
    }
    CourseTableSetting setting = populate(CourseTableSetting.class, "setting");
    setting.setSemester(semester);
    setting.setTimes(getTimesFormPage(semester));
    if (Strings.isEmpty(setting.getKind())) {
      return forwardError("error.courseTable.unknown");
    }
    // 查找课表对象
    String ids = get("ids");
    if (Strings.isEmpty(ids)) {
      put("prompt", "common.lessOneSelectPlease");
      return forward("prompt");
    }
    Class<Entity<?>> clazzType = CourseTable.getResourceClass(setting.getKind());
    Class idClazz = Model.getType(clazzType).getIdType();
    List<Object> rsList = CollectUtils.newArrayList();
    for (String a : Strings.split(ids)) {
      rsList.add(DefaultConversion.Instance.convert(a, idClazz));
    }
    OqlBuilder<Entity<?>> entityQuery = OqlBuilder.from(clazzType, "resource").where("resource.id in (:ids)",
        rsList);
    List<Entity<?>> resources = entityDao.search(entityQuery);

    List<Order> orders = Order.parse(get("setting.orderBy"));
    if (orders.isEmpty()) {
      orders.add(new Order("code asc"));
    }
    Order order = (Order) orders.get(0);
    // 临时解决一下打印排序报错问题
    Collections.sort(resources,
        new PropertyComparator(getLastSubString(order.getProperty()), order.isAscending()));

    // 组装课表，区分单个课表和每页多个课表两种情况
    List<Object> courseTableList = CollectUtils.newArrayList();
    if (setting.getTablePerPage() == 1) {
      for (Entity<?> resource : resources) {
        courseTableList.add(buildCourseTable(setting, resource));
      }
    } else {
      int i = 0;
      MultiCourseTable multiTable = null;
      for (Entity<?> resource : resources) {
        if (i % setting.getTablePerPage() == 0) {
          multiTable = new MultiCourseTable();
          courseTableList.add(multiTable);
        }
        multiTable.getResources().add(resource);
        multiTable.getTables().add(buildCourseTable(setting, resource));
        i++;
      }
    }
    setting.setWeekdays(Arrays.asList(WeekTimeBuilder.getWeekDays(semester)));
    setting.setDisplaySemesterTime(true);
    put("courseTableList", courseTableList);
    if (setting.getTablePerPage() == 1 && !setting.getIgnoreTask()) {
      Map<Clazz, Set<Textbook>> textbookMap = CollectUtils.newHashMap();
      Map<Entity<?>, Map<Clazz, CourseTaker>> courseTakerMap = CollectUtils.newHashMap();
      for (Object object : courseTableList) {
        CourseTable table = (CourseTable) object;
        if (CourseTable.STD.equals(setting.getKind())) {
          courseTakerMap.put(table.getResource(), new HashMap<Clazz, CourseTaker>());
        }
        for (Clazz clazz : table.getClazzes()) {
          if (CourseTable.STD.equals(setting.getKind())) {
            courseTakerMap.get(table.getResource()).put(
                clazz,
                (entityDao.search(OqlBuilder.from(CourseTaker.class, "courseTaker").where(
                    "courseTaker.clazz=:clazz and courseTaker.std.id = :id", clazz,
                    table.getResource().getId()))).get(0));
          }
          List<Material> clazzMaterials = entityDao.get(Material.class, "clazz", clazz);
          if (!clazzMaterials.isEmpty()) {
            Material clazzMaterial = clazzMaterials.get(0);
            if (clazzMaterial.getPassed() != null && Boolean.TRUE.equals(clazzMaterial.getPassed())) {
              textbookMap.put(clazz, CollectUtils.newHashSet(clazzMaterials.get(0).getBooks()));
            }
          }
        }
      }
      put("courseTakerMap", courseTakerMap);
      put("textbookMap", textbookMap);
    }
    put("setting", setting);
    put("timeSetting", timeSettingService.getClosestTimeSetting(getProject(), setting.getSemester(), null));
    put("tableStyle", CourseTableStyle.getStyle((String) getConfig().get(CourseTableStyle.STYLE_KEY)));
    put("courseHourTypes", codeService.getCodes(CourseHourType.class));
    if (CourseTable.CLASS.equals(setting.getKind())) {
      put("squadClazzGroups", squadClazzGroups);
      put("squadCourseGroups", squadCourseGroups);
    }
    put("weekStates", new WeekStates());
    if (1 == setting.getTablePerPage()) {
      return forward();
    } else {
      return forward("courseTable_" + setting.getStyle());
    }
  }

  /**
   * 工程技术大学的体育课程表 找出所有的Session(activity.task.semester.id=?,
   * activity.task.course.id in(?)) distinct Session.time.weekId,
   * distinct Session.time.beginAt, endUnit
   *
   * @return
   */
  public String peCourseTable() {
    String[] peCourseCodes = get("pe.courseCodes").trim().split("\\s*,\\s*");
    Semester semester = getSemester();
    List<Integer> weekIds = getDistinctWeekdays(peCourseCodes, semester);
    List<Integer[]> unitRanges = getDistinctUnitRanges(peCourseCodes, semester);

    StringBuilder arrangeQuery = new StringBuilder();
    arrangeQuery
        .append("select distinct \n")
        .append("    activity.time.weekday,\n")
        .append("    activity.time.beginAt,\n")
        .append("    activity.time.endAt,\n")
        .append("    clazz.course.code, \n")
        .append(
            "    (select count(ss.std.id) from adminClass.stdStates ss where ss.std.person.gender.id=1), \n")
        .append(
            "    (select count(ss.std.id) from adminClass.stdStates ss where ss.std.person.gender.id=2) \n")
        .append("from\n").append("  org.openurp.edu.course.model.Clazz clazz \n")
        .append("    join clazz.schedule.sessions activity\n").append("where\n")
        .append("clazz.semester=:semester\n").append("and clazz.course.code in (:peCourseCodes)\n")
        .append("size(esson.courseSchedule.activities)>0\n").append("order by\n")
        .append("    activity.time.weekId,\n").append("    activity.time.beginAt,\n")
        .append("    activity.time.endAt,\n").append("    clazz.course.code,\n");
    // .append(" adminClass.name");
    Map<String, Object> arrangeQueryParams = CollectUtils.newHashMap();
    arrangeQueryParams.put("peCourseCodes", peCourseCodes);
    arrangeQueryParams.put("semester", semester);
    List<Object[]> arranges = entityDao.search(arrangeQuery.toString(), arrangeQueryParams);

    StringBuilder courseQuery = new StringBuilder();
    courseQuery.append("select distinct course from Course course where course.code in(:courseCodes)\n");
    Map<String, Object> courseQueryParams = CollectUtils.newHashMap();
    courseQueryParams.put("courseCodes", peCourseCodes);
    List<Course> courses = entityDao.search(courseQuery.toString(), courseQueryParams);

    Map<String, String> courseCodeNameMap = new HashMap<String, String>();
    for (int i = 0; i < courses.size(); i++) {
      courseCodeNameMap.put(courses.get(i).getCode(), courses.get(i).getName());
    }

    put("unitRanges", unitRanges);
    put("weekIds", weekIds);
    put("arranges", arranges);
    put("courseCodeNameMap", courseCodeNameMap);

    return forward();
  }

  /**
   * mainly help peCourseTable
   *
   * @param courseCodes
   * @param semester
   * @return
   */
  @SuppressWarnings("unchecked")
  private List<Integer> getDistinctWeekdays(String[] courseCodes, Semester semester) {
    OqlBuilder<?> weekDayQuery = OqlBuilder.from(Session.class, "activity")
        .select("select distinct activity.time.weekday")
        .where("activity.clazz.course.code in (:peCourseCodes)", courseCodes)
        .where("activity.clazz.semester=:semester", semester).orderBy("activity.time.weekday");
    return (List<Integer>) entityDao.search(weekDayQuery);
  }

  /**
   * mainly help peCourseTable
   *
   * @param courseCodes
   * @param semester
   * @return
   */
  @SuppressWarnings("unchecked")
  private List<Integer[]> getDistinctUnitRanges(String[] courseCodes, Semester semester) {
    OqlBuilder<?> unitRangeQuery = OqlBuilder.from(Session.class, "activity")
        .select("select distinct activity.time.beginAt, activity.time.endAt")
        .where("activity.clazz.course.code in (:peCourseCodes)", courseCodes)
        .where("activity.clazz.semester=:semester", semester);
    List<Order> orders = CollectUtils.newArrayList(new Order("activity.time.beginAt"), new Order(
        "activity.time.endAt"));
    unitRangeQuery.orderBy(orders);
    List<?> res = entityDao.search(unitRangeQuery);
    CollectionUtils.transform(res, new Transformer() {

      public Object transform(Object input) {
        Object[] arr = (Object[]) input;
        Integer[] ret = new Integer[arr.length];
        for (int i = 0; i < arr.length; i++) {
          ret[i] = (Integer) arr[i];
        }
        return ret;
      }
    });
    return (List<Integer[]>) res;
  }

  protected <T extends Entity<?>> List<Clazz> getClazzes(Semester semester, T entity) {
    OqlBuilder<Clazz> builder = OqlBuilder.from(Clazz.class, "clazz");
    builder.where("clazz.project = :project", getProject());
    builder.where("clazz.semester =:semester", semester);
    Condition con = CourseLimitUtils.build(entity, "lgi");
    List<?> params = con.getParams();
    builder.where("exists(from clazz.enrollment.restrictions lg join lg.items as lgi where (lgi.operator='"
        + Operator.EQUAL.name() + "' or lgi.operator='" + Operator.IN.name() + "') and " + con.getContent()
        + ")", params.get(0), params.get(1), params.get(2));
    return entityDao.search(builder);
  }

  /**
   * 构建一个课程表
   *
   * @param setting
   * @param resource
   * @return
   */
  protected CourseTable buildCourseTable(CourseTableSetting setting, Entity<?> resource) {
    CourseTable table = new CourseTable(resource, setting.getKind());
    List<Clazz> taskList = null;
    if (CourseTable.CLASS.equals(setting.getKind())) {
      // for (int j = 0; j < setting.getTimes().length; j++) {
      table.getActivities().addAll(
          teachResourceService.getSquadActivities((Squad) resource, new WeekTime(),
              setting.getForSemester() ? setting.getSemester() : null));
      // }
      if (setting.getIgnoreTask())
        return table;
      Squad adminClass = (Squad) resource;
      taskList = getClazzes(setting.getSemester(), resource);
      MajorPlan plan = majorPlanService.getMajorPlanByAdminClass(adminClass);
      Set<CourseGroup> courseGroups = CollectUtils.newHashSet();
      Map<CourseType, Float> newCourseGroups = CollectUtils.newHashMap();
      Set<Course> courses = CollectUtils.newHashSet();
      Map<CourseType, Set<Clazz>> newClazzGroups = CollectUtils.newHashMap();
      for (Clazz clazz : taskList) {
        CourseType courseType = clazz.getCourseType();
        if (newClazzGroups.containsKey(courseType)) {
          newClazzGroups.get(courseType).add(clazz);
        } else {
          CourseGroup courseGroup = plan == null ? null : plan.getGroup(clazz.getCourseType());
          newClazzGroups.put(courseType, CollectUtils.newHashSet(clazz));
          newCourseGroups.put(courseType, (null == courseGroup) ? 0 : courseGroup.getCredits());
          if (null != courseGroup)
            courseGroups.add(courseGroup);
        }
        if (!courses.contains(clazz.getCourse())) {
          courses.add(clazz.getCourse());
        }
      }
      squadCourseGroups.put(adminClass, newCourseGroups);
      squadClazzGroups.put(adminClass, newClazzGroups);
    } else if (CourseTable.TEACHER.equals(setting.getKind())) {
      Teacher teacher = (Teacher) resource;
      put("teacher", resource);
      for (int j = 0; j < setting.getTimes().length; j++) {
        table.getActivities().addAll(
            teachResourceService.getTeacherActivities(teacher, setting.getTimes()[j],
                setting.getForSemester() ? setting.getSemester() : null));
      }
      if (setting.getIgnoreTask()) {
        return table;
      }
      if (setting.getForSemester()) {
        taskList = clazzService.getClazzByCategory(resource.getId(),
            clazzFilterStrategyFactory.getClazzFilterCategory(ClazzFilterStrategy.TEACHER),
            setting.getSemester());
      } else {
        taskList = clazzService.getClazzByCategory(resource.getId(),
            clazzFilterStrategyFactory.getClazzFilterCategory(ClazzFilterStrategy.TEACHER),
            semesterService.getSemestersOfOverlapped(setting.getSemester()));
      }
    } else if (CourseTable.STD.equals(setting.getKind())) {
      Student student = (Student) resource;
      for (int j = 0; j < setting.getTimes().length; j++) {
        table.getActivities().addAll(
            teachResourceService.getStdActivities(student, setting.getTimes()[j],
                setting.getForSemester() ? setting.getSemester() : null));
      }
      if (setting.getIgnoreTask()) {
        return table;
      }
      if (setting.getForSemester()) {
        taskList = clazzService
            .getClazzByCategory(resource.getId(),
                clazzFilterStrategyFactory.getClazzFilterCategory(ClazzFilterStrategy.STD),
                setting.getSemester());
      } else {
        taskList = clazzService.getClazzByCategory(resource.getId(),
            clazzFilterStrategyFactory.getClazzFilterCategory(ClazzFilterStrategy.STD),
            semesterService.getSemestersOfOverlapped(setting.getSemester()));
      }
    } else if (CourseTable.ROOM.equals(setting.getKind())) {
      Classroom classroom = (Classroom) resource;
      boolean notShowAll = getBool("notShowAll");
      for (int j = 0; j < setting.getTimes().length; j++) {
        if (notShowAll) {
          table.getActivities().addAll(
              teachResourceService.getRoomActivities(classroom, setting.getTimes()[j],
                  setting.getForSemester() ? setting.getSemester() : null, getDeparts(), getProject()));
        } else {
          table.getActivities().addAll(
              teachResourceService.getRoomActivities(classroom, setting.getTimes()[j],
                  setting.getForSemester() ? setting.getSemester() : null));
        }
      }
      if (setting.getIgnoreTask()) {
        return table;
      }
      // 教室的教学任务列表从教学活动中抽取
      table.extractTaskFromActivity();
    }
    if (null == table.getClazzes())
      table.setClazzes(taskList);
    return table;
  }

  /**
   * 如果课程表要扩展到支持每周的课表显示， 则可以用次函数和resoureceService服务 查询、显示教学活动.
   *
   * @param semester
   * @return
   */
  protected WeekTime[] getTimesFormPage(Semester semester) {
    Integer startWeek = getInt("startWeek");
    Integer endWeek = getInt("endWeek");
    if (null == startWeek)
      startWeek = new Integer(1);
    if (null == endWeek)
      endWeek = new Integer(semester.getWeeks());
    if (startWeek.intValue() < 1)
      startWeek = new Integer(1);
    if (endWeek.intValue() > semester.getWeeks())
      endWeek = new Integer(semester.getWeeks());
    put("startWeek", startWeek);
    put("endWeek", endWeek);
    if (endWeek.intValue() > semester.getWeeks())
      endWeek = new Integer(semester.getWeeks());
    int[] weeks = NumberSequence.build(startWeek, endWeek, NumberSequence.Pattern.CONTINUE);
    List<WeekTime> times = new ArrayList<WeekTime>();
    for (WeekDay wd : WeekDay.All) {
      for (WeekTime wt : WeekTimeBuilder.on(semester).build(wd, weeks)) {
        times.add(wt);
      }
    }
    return times.toArray(new WeekTime[times.size()]);
  }

  /**
   * 按照"."截断,取最后一截
   *
   * @param str
   * @return
   */
  private String getLastSubString(String str) {
    if (null == str) {
      return null;
    }
    String[] subStrArr = Strings.split(str, ".");
    if (subStrArr.length > 0) {
      return subStrArr[subStrArr.length - 1];
    } else {
      return null;
    }
  }

  public String getArrangedClazzes() {
    String crn = get("crn");
    String courseNo = get("courseNo");
    String courseName = get("courseName");
    Integer teachDepartId = getInt("teachDepartId");
    Integer semesterId = getInt("semesterId");
    if (Strings.isEmpty(courseName) && Strings.isEmpty(crn) && Strings.isEmpty(courseNo)
        && teachDepartId == null || semesterId == null) {
      put("clazzes", Collections.emptyList());
    } else {
      OqlBuilder<Clazz> builder = OqlBuilder.from(Clazz.class, "clazz");
      if (Strings.isNotEmpty(crn)) {
        builder.where(Condition.like("clazz.crn", crn));
      }
      if (Strings.isNotEmpty(courseNo)) {
        builder.where(Condition.like("clazz.course.code", courseNo));
      }
      if (Strings.isNotEmpty(courseName)) {
        builder.where(Condition.like("clazz.course.name", courseName));
      }
      if (null != teachDepartId) {
        builder.where("clazz.teachDepart.id = :teachDepartId", teachDepartId);
      }
      builder.where("clazz.semester.id = :semesterId", semesterId);
      builder.where("size(clazz.schedule.sessions)>0");
      builder.where("clazz.project.id=:projectid1", projectContext.getProjectId());
      put("clazzes", entityDao.search(builder));
    }
    return forward("arrangedClazzes");
  }

  public String getClazzActivities() {
    Long[] clazzIds = Strings.splitToLong(get("clazzIds"));
    List<Clazz> clazzes = CollectUtils.newArrayList();
    List<Session> activities = CollectUtils.newArrayList();
    Integer semesterId = getInt("semesterId");
    if (null == semesterId) {
      return forwardError("没有找到学期");
    }
    Semester semester = entityDao.get(Semester.class, semesterId);
    if (ArrayUtils.isNotEmpty(clazzIds)) {
      clazzes = entityDao.get(Clazz.class, clazzIds);
      for (Clazz clazz : clazzes) {
        activities.addAll(clazz.getSchedule().getSessions());
      }
    } else {
      return forwardError("没有找到教学任务");
    }
    put("startWeek", new Integer(1));
    put("endWeek", new Integer(semester.getWeeks()));
    put("weekList", WeekTimeBuilder.getWeekDays(semester));
    put("activityList", activities);
    put("clazzes", clazzes);
    put("clazzIds", get("clazzIds"));
    put("semester", semester);
    put("timeSetting", timeSettingService.getClosestTimeSetting(getProject(), semester, null));
    put("tableStyle", CourseTableStyle.getStyle((String) getConfig().get(CourseTableStyle.STYLE_KEY)));
    if (getBool("print")) {
      return forward("courseTableClazzForPrint");
    } else {
      return forward("courseTableClazz");
    }
  }

  public void setClazzService(ClazzService clazzService) {
    this.clazzService = clazzService;
  }

  public void setStudentService(StudentService studentService) {
    this.studentService = studentService;
  }

  public void setTeachResourceService(TeachResourceService teachResourceService) {
    this.teachResourceService = teachResourceService;
  }

  public void setMajorPlanService(MajorPlanService majorPlanService) {
    this.majorPlanService = majorPlanService;
  }

  public void setBaseInfoSearchHelper(BaseInfoSearchHelper baseInfoSearchHelper) {
    this.baseInfoSearchHelper = baseInfoSearchHelper;
  }

  public void setStdSearchHelper(StdSearchHelper stdSearchHelper) {
    this.stdSearchHelper = stdSearchHelper;
  }

  public void setClazzFilterStrategyFactory(ClazzFilterStrategyFactory clazzFilterStrategyFactory) {
    this.clazzFilterStrategyFactory = clazzFilterStrategyFactory;
  }
}
