[#ftl]
[@b.head/]
[#include "/template/macros.ftl"/]
[@b.grid items=squades var="squad"]
  [@b.gridbar]
    bar.addItem("大课表", "courseTableOfClass()");
       bar.addItem("${b.text('action.selectPreview')}",'printCourseTable()');
  [/@]
  [@b.row]
     [@b.boxcol/]
     [@b.col property="grade" title="std.state.grade"  width="10%"/]
     [@b.col property="name" title="attr.name" width="35%"]
       [@b.a href="!courseTable?setting.kind=class&setting.forSemester=1&semester.id=${semester.id}&ids=${squad.id}" target="_blank" title="查看班级课表"][@i18nName squad/][/@]
     [/@]
     [@b.col property="span" title="entity.EduSpan" width="10%"]${(squad.span.name)!}[/@]
     [@b.col property="stdType" title="entity.studentType" width="10%"]${(squad.stdType.name)!}[/@]
     [@b.col property="department" title="院系" width="15%"]${(squad.department.name)!}[/@]
     [@b.col property="major" title="entity.major" width="15%"]${(squad.major.name)!} ${(squad.direction.name)!}[/@]
   [/@]
[/@]
[#assign courseTableType="class"]
[#include "courseTableSetting.ftl"/]
 <script language="javascript">
    function courseTableOfClass() {
      var form = document.courseTableSearchForm;
      var adminClassIds = bg.input.getCheckBoxValues("squad.id");
      if(null==adminClassIds || ""==adminClassIds){
        alert("请选择一个或多个操作");
        return;
      }
      bg.form.addInput(form,"adminClassIds",adminClassIds);
      bg.form.addInput(form,"semester.id","${(semester.id)!}")
      bg.form.submit(form,"usstCourseTable!courseTableOfClass.action","_blank");
    }
  </script>
[@b.foot/]
