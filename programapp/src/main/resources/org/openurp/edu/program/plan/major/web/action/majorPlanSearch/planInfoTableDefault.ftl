[#ftl]
<div style="text-indent: 2em;"><p style="color:#00108c;font-weight:bold;font-size:10pt;text-align:left;">六.课程设置及学时安排</p></div>
[#assign maxTerm = plan.termsCount /]
[#if Parameters['term']??]
[#assign term = Parameters['term']]
[/#if]
[#include "../../../../ftllib/planFunctions.ftl" /]
<table border="0" width="100%" align="center">
    <tr>
        <td align="center">
            <table id="planInfoTable${plan.id}" name="planInfoTable${plan.id}" class="planTable"  style="font-size:12px;font-family:宋体;vnd.ms-excel.numberformat:@" width="95%">
                [#assign maxTerm=plan.termsCount /]
                <thead>
                    <tr align="center">
                        <td rowspan="2" colspan="${maxFenleiSpan}" width="5%">课程性质</td>
                        <td rowspan="2" width="10%">${b.text("attr.courseNo")}</td>
                        <td rowspan="2" width=20%">${b.text("attr.courseName")}</td>
                        <td rowspan="2" width="5%">${b.text("attr.credit")}</td>
                        <td rowspan="2" width="5%">学时</td>
                        <td colspan="3" width="16%">学时分配</td>
                        <td rowspan="2" width="5%">课程设计</td>
                        <td rowspan="2" width="5%">毕业设计</td>
                        <td colspan="${maxTerm}" width="30%">按学期学分分配</td>
                    </tr>
                    <tr>
                    [#list ["讲课","实验","上机"] as n]
                      <td width="5%" ><p align="center">${n}</p></td>
                    [/#list]
                    [#assign total_term_credit={} /]
                    [#list 1..maxTerm as i ]
                        [#assign total_term_credit=total_term_credit + {i:0} /]
                        <td width="[#if maxTerm?exists&&maxTerm!=0]${30/maxTerm}[#else]2[/#if]%"><p align="center">${i}</p></td>
                    [/#list]
                    </tr>
                </thead>
                <tbody>
                [#list plan.topCourseGroups! as courseGroup]
                    [@drawGroup courseGroup planCourseCreditInfo courseGroupCreditInfo/]
                [/#list]
                    [#-- 绘制总计 --]
                    <tr>
                        <td class="summary" colspan="${maxFenleiSpan + mustSpan}">${b.text("attr.cultivateScheme.allTotle")}</td>
                        <td class="credit_hour summary">${plan.credits!(0)}</td>
                        <td class="credit_hour summary">&nbsp;</td>
                        <td class="credit_hour summary">&nbsp;</td>
                        <td class="credit_hour summary">&nbsp;</td>
                        <td class="credit_hour summary">&nbsp;</td>
                        <td class="credit_hour summary">&nbsp;</td>
                        <td class="credit_hour summary">&nbsp;</td>
                    [#list 1..maxTerm as i]
                        <td class="credit_hour">${total_term_credit[i?string]}</td>
                    [/#list]
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                    </tr>
                </tbody>
            </table>
        </td>
    </tr>
</table>
<script>
[@mergeCourseTypeCell plan teachPlanLevels 2/]
</script>
