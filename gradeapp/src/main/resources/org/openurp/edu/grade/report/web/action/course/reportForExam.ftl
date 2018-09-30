[#ftl]
[@b.head/]
[#include "/template/macros.ftl"/]
[#include "/template/print.ftl"/]
[@b.toolbar title="试卷分析表"]
     bar.addPrint();
     bar.addClose();
[/@]
<style type="text/css">
body{
 font-family:楷体_GB2312;
 font-size:14px;
}
.reportTable {
  border-collapse: collapse;
    border:solid;
  border-width:1px;
    border-color:black;
    vertical-align: middle;
    font-style: normal;
  font-family:楷体_GB2312;
  font-size:15px;
}
table.reportTable td{
  border:solid;
  border-width:1px;
  border-right-width:1;
  border-bottom-width:1;
  border-color:black;

}
</style>
<div id="DATA" width="100%">
[#list courseStats as courseStat]
  [#assign teachTask=courseStat.clazz]
  [#if courseStat.gradeSegStats.size()>0]
  [@b.div style="text-align:center"]
    <div><h2>[@i18nName teachTask.project.school!/]课程考核试卷分析表</h2></div>
    <div style="margin-bottom: 45px"><span style="margin-right: 30px">(${teachTask.semester.schoolYear!}学年</span><span>${(teachTask.semester.name)?if_exists?replace("1","第一")?replace("2","第二")}学期)<span></div>
  [/@]
    <table align="center" width="95%" border='0' style="font-weight:bold;">
      <tr>
      <td>开课院(系、部):[@i18nName teachTask.teachDepart/]</td>
      <td>授课班级:${teachTask.name}</td>
        <td>主讲教师:[@getTeacherNames teachTask.teachers?if_exists/]</td>
      </tr>
      <tr>
        <td>${b.text("attr.taskNo")}:${teachTask.crn?if_exists}</td>
          <td>${b.text("attr.courseName")}:[@i18nName teachTask.course/]</td>
        <td>${b.text("entity.courseType")}:[@i18nName teachTask.courseType/]</td>
      </tr>
    </table>   <br/>
     [#list courseStat.gradeSegStats as gradeStat]
     <table width="95%" align="center" class="reportTable">
       <tr>
           <td rowspan="5">期末考试成绩统计</td>
          <td align="left">分数段</td>
          [#list gradeStat.scoreSegments as seg]
          <td align="center">${seg.min?string("##.#")}-${seg.max?string("##.#")}</td>
          [/#list]
       </tr>
       <tr align="center">
          <td align="left">人数</td>
          [#list gradeStat.scoreSegments as seg]
          <td>${seg.count}</td>
          [/#list]
       </tr>
       <tr align="center">
          <td align="left">比例数</td>
          [#list gradeStat.scoreSegments as seg]
          <td>${((seg.count/gradeStat.stdCount)*100)?string("##.#")}%</td>
          [/#list]
       </tr>
       <tr align="center">
          <td align="left">最高分</td>
          <td>[#if gradeStat.heighest?exists]${gradeStat.heighest?string("##.#")}[/#if]</td>
          <td align="left">最低分</td>
          <td colspan="1">[#if gradeStat.lowest?exists]${gradeStat.lowest?if_exists?string("##.#")}[/#if]</td>
          <td align="left">平均分</td>
          <td colspan="1">${(gradeStat.average?string("##.#"))?default('')}</td>
       </tr>
       <tr align="center">
          <td align="left">实考人数</td>
          <td>${gradeStat.stdCount}</td>
          <td></td>
          <td></td>
          <td></td>
          <td></td>
       </tr>
       <tr>
       <td colspan="9">
        试题分析：考试内容的覆盖面、难易程度及课程教学大纲要求相符程度[#list 1..10 as  i]<br>[/#list]&nbsp;<br>
       </td>
       </tr>
       <tr>
       <td colspan="9">
        考试结果分析：学生对本课程教学大纲规定应掌握的基本理论、基本知识和基本技能实际掌握情况[#list 1..10 as  i]<br>[/#list]&nbsp;<br>
       </td>
       </tr>
       <tr>
       <td colspan="9">
        其他：根据考试结果分析，本课程教学存在的主要问题和改进意见[#list 1..10 as  i]<br>[/#list]&nbsp;<br>
       </td>
       </tr>
     </table>
     [/#list]

     <table align="center" width="95%" border='0' style="font-size:15px;">
     <tr>
       <td  colspan="${2+segStat.scoreSegments?size}">
          [@b.div style="text-align:right;"]授课老师签名:<U>[#list 1..50 as  i]&nbsp;[/#list]</U>&nbsp;&nbsp;[/@]
          [@b.div style="text-align:right;"]院系部主任签名:<U>[#list 1..50 as  i]&nbsp;[/#list]</U>&nbsp;&nbsp;[/@]
          [@b.div style="text-align:right;"]日期:<U>[#list 1..50 as  i]&nbsp;[/#list]</U>&nbsp;&nbsp;[/@]
       </td>
     </tr>
    </table>
  [#else]
       <table width="95%" align="center">
         <tr><td>
       [@b.div style="width:95%;text-align:left;margin-top:20px;color:red;"]
         ${teachTask.semester.schoolYear}学年${teachTask.semester.name}学期,${teachTask.name!}，${teachTask.course.name} 没有出卷考试，无需打印填写试卷分析表。
       [/@]
      </td></tr></table>
  [/#if]
[/#list]
</div>
<form method="post" action="" name="actionForm">
  <input type="hidden" name="clazz.ids" value="${Parameters['clazz.ids']?default('')}"/>
</form>
<SCRIPT LANGUAGE="javascript">
 //指定页面区域内容导入Excel
 function AllAreaExcel()  {
  var oXL= newActiveX("Excel.Application");
  if(null==oXL) return;
  var oWB = oXL.Workbooks.Add();
  var oSheet = oWB.ActiveSheet;
  var sel=document.body.createTextRange();
  sel.moveToElementText(PrintA);
  sel.select();
  sel.execCommand("Copy");
  oSheet.Paste();
  oXL.Visible = true;
 }
[@b.foot/]
