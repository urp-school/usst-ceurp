[#ftl]
[@b.head/]
[#assign _pageSize = 50/]
[#assign gradePerColumn = (_pageSize / 2)?int/]
[#assign fontSize = 10/]
[#assign style]style="font-size: ${fontSize}pt;font-weight: bolder;font-family:黑体;"[/#assign]
[#assign width = "6%"/]
<style>
table.usst {
  ;
}
table.usst td {
  padding: 3px;
}
table.listTable {
  font-family: 宋体;
  border-collapse: collapse;
  border-style:solid;
  border-width:1px;
  border-color:#006CB2;
  vertical-align: middle;
  font-style: normal;
  text-align: center;
}
table.listTable td{
  border-style:solid;
  border-width:1px;
  border-color:#006CB2;
  padding: 0px;
  font-size:${fontSize-2}pt;
}
</style>
[#assign spring = ['01','02','03','04','05','06','07']/]
[#assign courseTypaAlias = {"专业基础类":"专基"}/]

[#list students as std]
  <div align='center' style="font-size:${fontSize+2}pt;font-weight: bolder;font-family:黑体;margin-top: 15mm;margin-bottom: 10"><span style="letter-spacing: ${(fontSize) / 3}pt">上海理工大学继续教育学院学生成绩档案</span><span>表</span></div>
    <table ${style} width="100%">
      <tr>
        <td>学号：${std.user.code}</td>
        <td>姓名：${std.user.name}</td>
        <td>性别：${(std.person.gender.name)!}</td>
        <td>专业：${std.state.major.name}</td>
        <td>学历层次：${std.level.name}</td>
        <td>学习形式：${(std.studyType.name)!}</td>
     <tr>
    </table>
    <table ${style} width="100%">
      <tr>
        <td>身份证号:${std.person.code}</td>
        <td>入学年份:${std.beginOn?string("yyyy")}</td>
        <td>入学季节:${(std.beginOn?string("M")?number lte 7)?string("春季","秋季")}</td>
        <td>修读年限:<span style="padding-right: 3px">${std.duration}</span>年</td>
        <td>教学站点:${(std.state.department.shortName)?default(std.state.department)}</td>
      </tr>
    </table>
    [#assign stdGrades = grades.get(std)/]
    [#assign result = semesterGroup.courseGradeBy2Semester(stdGrades)/]
    [#assign semesters = (result.semesters?sort_by("beginOn"))?if_exists/]
    <table class="usst" width="100%" align="center">
      <tr valign="top">
      [#list semesters as semester]
        [#if semester_index != 0 && semester_index % 2 == 0]
      </tr>
      <tr valign="top">
        [/#if]
        <td width="50%">
          <table style="font-size:${fontSize-2}pt" width="100%" class="listTable">
            <tr align="center">
              <td colspan="10">${semester.schoolYear}学年</td>
            </tr>
            <tr align="center">
              <td colspan="5" width="50%">春季</td>
              <td colspan="5" width="50%">秋季</td>
            </tr>
            <tr align="center">
              <td>课程名称</td>
              <td width="${width}" style="white-space: nowrap">学分</td>
              <td width="${width}" style="white-space: nowrap">学时</td>
              <td width="${width}" style="white-space: nowrap">得分</td>
              <td width="${width}" style="white-space: nowrap">类型</td>
              <td>课程名称</td>
              <td width="${width}" style="white-space: nowrap">学分</td>
              <td width="${width}" style="white-space: nowrap">学时</td>
              <td width="${width}" style="white-space: nowrap">得分</td>
              <td width="${width}" style="white-space: nowrap">类型</td>
            </tr>
            [#assign firstHalf = (result[semester.schoolYear].firstHalf?sort_by(["course","code"]))?if_exists/]
            [#assign secondHalf = (result[semester.schoolYear].secondHalf?sort_by(["course","code"]))?if_exists/]
            [#assign firstRow = (firstHalf?size)?default(0)/]
            [#assign secondRow = (secondHalf?size)?default(0)/]
            [#assign maxRow = (firstRow gte secondRow)?string(firstRow, secondRow)?number/]
            [#list 0..maxRow - 1 as rowIndex]
            <tr>
              <td style="text-align: left">${(firstHalf[rowIndex].course.name)!}</td>
              <td>${(firstHalf[rowIndex].course.credits)!}</td>
              <td>${(firstHalf[rowIndex].course.creditHours)!}</td>
              <td>${(firstHalf[rowIndex].scoreText)!}</td>
              <td>${(courseTypaAlias[firstHalf[rowIndex].courseType.name]!(firstHalf[rowIndex].courseType.name[0..1]))!}</td>
              <td style="text-align: left">${(secondHalf[rowIndex].course.name)!}</td>
              <td>${(secondHalf[rowIndex].course.credits)!}</td>
              <td>${(secondHalf[rowIndex].course.creditHours)!}</td>
              <td>${(secondHalf[rowIndex].scoreText)!}</td>
              <td>${(courseTypaAlias[secondHalf[rowIndex].courseType.name]!(secondHalf[rowIndex].courseType.name[0..1]))!}</td>
            </tr>
            [/#list]
          </table>
        </td>
      [/#list]
      </tr>
    </table>
    [#assign semesters = []/]
    <table ${style} width="80%">
      <tr>
        <td width="16%">平均分:</td><td width="28%">${(gpas.get(std).ga)!}</td>
        <td></td>
        <td></td>
        <td></td>
        <td width="20%"></td>
        <td></td>
        <td></td>
      </tr>
    [#list externExamGrades.get(std)?if_exists as externExamGrade]
      <tr>
        <td>英语证书类型:</td><td>${externExamGrade.subject.name}</td><td>获得日期:</td><td>${(externExamGrade.acquiredOn?string("yyyy-MM"))!}</td><td>证书编号:</td><td>${externExamGrade.certificate!""}</td><td>分数:</td><td>${externExamGrade.scoreText!}</td>
      </tr>
    [/#list]

    [#if (graduationMap[std.id?string].code)??]
      <tr>
        <td>毕业证书编号:</td><td>${graduationMap[std.id?string].code}</td>
        <td>毕业日期:</td><td>${(graduationMap[std.id?string].graduateOn?string("yyyy-MM-dd"))!}</td>
        <td></td><td></td><td></td><td></td>
      </tr>
    [/#if]

    [#if (graduationMap[std.id?string].diplomaNo)??]
      <tr>
      <td>学士学位证书编号:</td><td>${graduationMap[std.id?string].diplomaNo!}</td>
      <td>获得日期:</td><td>${(graduationMap[std.id?string].degreeAwardOn?string("yyyy-MM-dd"))!""}</td>
      <td></td><td></td><td></td><td></td>
      </tr>
    [/#if]
  </table>

  <table ${style} width="100%">
    <tr>
      <td align="right" colspan="8">上海理工大学继续教育学院&nbsp;&nbsp;<br>
      [#if graduationMap[std.id?string].degreeAwardOn??]
      ${(graduationMap[std.id?string].degreeAwardOn?string("yyyy-MM-dd"))!}
      [#else]
      ${((graduationMap[std.id?string].graduateOn?string("yyyy-MM-dd"))!b.now?string('yyyy-MM-dd'))!}
      [/#if]
      &nbsp;&nbsp;
      </td>
    </tr>
   </table>
   [#if std_has_next]
     <div style='PAGE-BREAK-AFTER: always'></div>
   [/#if]
[/#list]
[@b.foot/]
