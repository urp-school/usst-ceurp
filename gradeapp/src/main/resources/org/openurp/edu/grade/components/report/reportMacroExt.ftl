[#ftl]
[#macro makeupReportFoot report]
    <table align="center" class="reportFoot" width="95%">
      <tr>
      <td width="10%">统计人数:${report.courseGrades?size}</td>
      <td width="20%"></td>
      <td width="30%">二级学院教学副院长（签章）:</td>
      <td width="20%">教师签名:</td>
      <td width="20%">成绩录入日期:${(report.courseGradeState.updatedAt?string('yyyy-MM-dd'))!}</td>
    </tr>
  </table>
[/#macro]

[#macro gaReportFoot report]
    <table align="center" class="reportFoot" width="95%">
      <tr>
      <td width="15%">统计人数:${totalNormal!0}</td>
      <td width="20%">总评平均成绩:[#if totalNormal>0]${totalNormalScore/totalNormal}[/#if]</td>
      <td width="25%">二级学院教学副院长（签章）:</td>
      <td width="20%">教师签名:</td>
      <td width="20%">成绩录入日期:${(report.courseGradeState.getState(GA).updatedAt?string('yyyy-MM-dd'))!}</td>
    </tr>
  </table>
[/#macro]
