[#ftl]
[@b.head/]
<style>
table.usst {
  ;
}
table.usst td {
  padding: 3px;
}
table.listTable {
  border-collapse: collapse;
  border-style:solid;
  border-width:1px;
  border-color:#006CB2;
  vertical-align: middle;
  font-style: normal;
}
table.listTable td{
  border-style:solid;
  border-width:1px;
  border-color:#006CB2;
}
</style>
[#assign _pageSize = 50/]
[#assign gradePerColumn = (_pageSize / 2)?int/]
[#assign fontSize = 10/]
[#assign style]style="font-size: ${fontSize}pt;font-weight: bolder;font-family:黑体;"[/#assign]

[#assign spring = ['01','02','03','04','05','06','07']/]
[#assign courseTypaAlias = {"专业基础类","专基"}/]
[#macro displayGrades(grade)]
  <td>${grade.course.name}</td>
  <td align='center'>${grade.course.credits?if_exists}</td>
  <td align='center'>${grade.getScoreText(GA)!}</td>
  <td align='center'>[#if courseTypaAlias[grade.courseType.name]??]${courseTypaAlias[grade.courseType.name]}[#else]${grade.courseType.name[0..1]}[/#if]</td>
[/#macro]

[#macro displayYearGrade(first, second, gradeCnt)]
  <table style="font-size:${fontSize-2}pt" width="100%" class="listTable">
    <tr align="center">
      <td colspan="8">[#if first?first??]${first?first.semester.schoolYear}|${first?first.semester.name}[#else]${second?first.semester.schoolYear}|${second?first.semester.name}[/#if]学年</td>
    </tr>
    <tr align="center">
      <td colspan="4">${(first?first.semester.name)?default("春季")}</td>
      <td colspan="4">${(second?first.semester.name)?default("秋季")}</td>
    </tr>
    <tr align="center">
      <td align="center" width="32%">课程名称</td>
      <td align="center" width="6%">学分</td>
      <td width="6%">得分</td>
      <td width="6%">类型</td>
      <td align="center" width="32%">课程名称</td>
      <td align="center" width="6%">学分</td>
      <td width="6%">得分</td>
      <td width="6%">类型</td>
    </tr>
  [#list 0..gradeCnt - 1 as i]
    <tr>
    [#if first[i]??][@displayGrades first[i]/][#else][#list 1..4 as i]<td><br></td>[/#list][/#if]
    [#if second[i]??][@displayGrades second[i]/][#else][#list 1..4 as i]<td><br></td>[/#list][/#if]
    </tr>
  [/#list]
  </table>
[/#macro]

[#list students as std]
  <div align='center' style="font-size:${fontSize+2}pt;font-weight: bolder;font-family:黑体;margin-top: 50;margin-bottom: 10"><span style="letter-spacing: ${(fontSize) / 3}pt">上海理工大学继续教育学院学生成绩档案</span><span>表</span></div>
    <table ${style} width="100%">
      <tr>
        <td>学号：${std.user.code}</td>
        <td>姓名：${std.user.name}</td>
        <td>性别：${(std.person.gender.name)!}</td>
        <td>专业：[#assign majorName = std.state.major.name/][#if (majorName?last_index_of("（")>0)]${majorName?substring(0, majorName?last_index_of("（"))}[#else]${majorName}[/#if]</td>
        <td>学历层次：${std.stdType.name}</td>
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
    [#assign stdGrades = grades.get(std)?sort_by(["semester", "beginOn"])/]
    [#assign maxSemesterId = (stdGrades[stdGrades?size - 1].semester.id)?default(-1)/]
    [#assign semesterIds = ""/]
    [#assign semesterIdsHas = ""/]
    [#list stdGrades as grade]
      [#if !semesterIds?contains("|" + grade.semester.id)]
        [#assign semesterIds = semesterIds + "|" + grade.semester.id/]
      [/#if]
      [#if !semesterIdsHas?contains("|" + grade.semester.id)]
        [#assign semesterIdsHas = semesterIdsHas + "|" + grade.semester.id/]
      [/#if]
      [#if (semesterMap[grade.semester.id?string].next)?? && !semesterIds?contains("|" + semesterMap[grade.semester.id?string].next.id) && (semesterMap[grade.semester.id?string].next.id) lt maxSemesterId]
        [#assign semesterIds = semesterIds + "|" + semesterMap[grade.semester.id?string].next.id/]
      [/#if]
    [/#list]
    [#assign semesterId = 0/]
    [#assign semesterGrades = []/]
    [#assign yearGrades = []/]

    [#assign semesterIdsStr = ""/]
    [#list stdGrades as grade]
      [#if grade.semester.id == semesterId]
        [#assign yearGrades = yearGrades + [grade]/]
      [#else]
        [#if semesterId != 0]
          [#assign yearGrades = yearGrades?sort_by(["course","code"])/]
          [#assign semesterGrades = semesterGrades + [yearGrades]/]
          [#if (semesterMap[yearGrades?first.semester.id?string].next)?? && !semesterIdsStr?contains("|" + semesterMap[yearGrades?first.semester.id?string].next.id) && semesterIds?contains("|" + semesterMap[yearGrades?first.semester.id?string].next.id) && !semesterIdsHas?contains("|" + semesterMap[yearGrades?first.semester.id?string].next.id)]
            [#assign semesterIdsStr = semesterIdsStr + "|" + semesterMap[yearGrades?first.semester.id?string].next.id/]
            [#assign yearGradess = []/]
            [#assign semesterGrades = semesterGrades + [yearGradess]/]
          [/#if]
        [/#if]
        [#if !semesterIdsStr?contains("|" + grade.semester.id)]
          [#assign semesterIdsStr = semesterIdsStr + "|" + grade.semester.id/]
        [/#if]
        [#assign yearGrades = [] + [grade]/]
        [#assign semesterId = grade.semester.id/]
      [/#if]
    [/#list]
    [#if yearGrades?size gt 0]
      [#assign yearGrades = yearGrades?sort_by(["course","code"])/]
      [#assign semesterGrades = semesterGrades + [yearGrades]/]
    [/#if]
    <table class="usst" width="100%" align="center">
      <tr valign="top">
    [#assign gradeCnt = 1/]
    [#list 0..3 as n]
       [#if semesterGrades[n]?? && semesterGrades[n]?size gt gradeCnt][#assign gradeCnt = semesterGrades[n]?size/][/#if]
    [/#list]
        <td width="50%">[#if semesterGrades[0]??][@displayYearGrade first = semesterGrades[0] second = semesterGrades[1]?if_exists gradeCnt = gradeCnt/][/#if]</td>
        <td width="50%">[#if semesterGrades[2]??][@displayYearGrade first = semesterGrades[2] second = semesterGrades[3]?if_exists gradeCnt = gradeCnt/][/#if]</td>
      </tr>
      <tr valign="top">
    [#assign gradeCnt = 1/]
    [#list 4..7 as n]
      [#if semesterGrades[n]?? && semesterGrades[n]?size gt gradeCnt][#assign gradeCnt = semesterGrades[n]?size/][/#if]
    [/#list]
        <td>[#if semesterGrades[4]??][@displayYearGrade first = semesterGrades[4] second = semesterGrades[5]?if_exists gradeCnt = gradeCnt/][/#if]</td>
        <td>[#if semesterGrades[6]??][@displayYearGrade first = semesterGrades[6] second = semesterGrades[7]?if_exists gradeCnt = gradeCnt/][/#if]</td>
      </tr>
      <tr valign="top">
    [#assign gradeCnt = 1/]
    [#list 8..11 as n]
      [#if semesterGrades[n]?? && semesterGrades[n]?size gt gradeCnt][#assign gradeCnt = semesterGrades[n]?size/][/#if]
    [/#list]
        <td>[#if semesterGrades[8]??][@displayYearGrade first = semesterGrades[8] second = semesterGrades[9]?if_exists gradeCnt = gradeCnt/][/#if]</td>
        <td>[#if semesterGrades[10]??][@displayYearGrade first = semesterGrades[10] second = semesterGrades[11]?if_exists gradeCnt = gradeCnt/][/#if]</td>
      </tr>
    </table>
    <table ${style} width="80%">
      <tr>
        <td width="16%">平均分:</td><td width="20%">${(gpas.get(std).ga)!}</td>
        <td></td>
        <td></td>
        <td></td>
        <td width="18%"></td>
        <td></td>
        <td></td>
      </tr>
    [#list externExamGrades.get(std)?if_exists as externExamGrade]
      <tr>
        <td>英语证书类型:</td><td>${externExamGrade.subject.name}</td><td>获得日期:</td><td>${(externExamGrade.examOn?string("yyyy-MM"))!}</td><td>证书编号:</td><td>${externExamGrade.examNo!""}</td><td>分数:</td><td>${externExamGrade.scoreText!}</td>
      </tr>
    [/#list]

    [#if (graduationMap[std.id?string].code)??]
      <tr><td>毕业证书编号:</td><td>${graduationMap[std.id?string].code}</td>
        <td>毕业日期:</td><td>${(graduationMap[std.id?string].graduateOn?string("yyyy-MM-dd"))!}</td>
        <td></td><td></td><td></td><td></td>
      </tr>
    [/#if>

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
      <td align="right" colspan="8">上海理工大学继续教育学院&nbsp;&nbsp;<br>${(b.now?string('yyyy年MM月dd日'))!}&nbsp;&nbsp;</td>
    </tr>
   </table>
   [#if std_has_next]
     <div style='PAGE-BREAK-AFTER: always'></div>
   [/#if>
[/#list>
[@b.foot/]
