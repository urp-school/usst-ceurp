[#ftl]
<div style="text-indent: 2em;"><p style="color:#00108c;font-weight:bold;font-size:10pt;text-align:left;">七.教学环节设置及学分分配</p></div>
[#assign maxTerm = plan.termsCount /]
[#if Parameters['term']??]
[#assign term = Parameters['term']]
[/#if]
[#include "../../../../ftllib/planFunctions.ftl" /]

    [#assign totalCredits=0/]
    [#assign bxllTotalCredits = 0]
    [#assign sxsjTotalCredits = 0]
    [#assign xxTotalCredits = 0]     [#--选修学分--]

    [#assign bxllCreditMap = {}]     [#--必修理论每学期学分--]
    [#assign sxsjCreditMap = {}]     [#--必修实习设计每学期学分--]
    [#assign xxCreditMap = {}]       [#--选修每学期学分--]

    [#assign bxllTotalCreditHour = 0][#--必修理论总学时--]
    [#assign sysjTotalCreditHour = 0][#--必修实验、上机总学时--]

    [#function isSXSJ course]
      [#local name=course.name/]
      [#return name?contains("课程设计")  ||  name?contains("毕业论文")  || name?contains("毕业设计") || name?contains("实习")]
    [/#function]

    [#list plan.topCourseGroups! as courseGroup]
      [#--必修课--]
      [#if courseGroup.compulsory]
        [#list courseGroup.planCourses as planCourse]
          [#if !isSXSJ(planCourse.course)]
            [#assign sysjHours= planCourse.course.getHourById(2)?default(0) + planCourse.course.getHourById(3)?default(0)/]
            [#assign bxllTotalCreditHour = bxllTotalCreditHour + planCourse.course.creditHours - sysjHours]
            [#assign sysjTotalCreditHour = sysjTotalCreditHour + sysjHours/]
            [#list 1..maxTerm as i]
                [#if planCourse.terms.contains(i)]
                [#assign bxllCreditMap = bxllCreditMap +{i?string: (planCourse.course.credits + (bxllCreditMap[i?string]!0))}]
                [/#if]
            [/#list]
          [#else]
          [#--必修中的实验上机,选修中的不考虑--]
            [#list 1..maxTerm as i]
                [#if planCourse.terms.contains(i)]
                [#assign sxsjCreditMap = sxsjCreditMap +{i?string: (planCourse.course.credits + (sxsjCreditMap[i?string]!0))}]
                [/#if]
            [/#list]
          [/#if]
        [/#list]
      [#else]
        [#--选修课--]
        [#assign i=1]
        [#assign termCredits= courseGroup.termCredits/]
        [#if termCredits?starts_with(",")]
            [#assign termCredits= termCredits[1..termCredits?length-1] /]
        [/#if]
        [#if termCredits?ends_with(",")]
            [#assign termCredits= termCredits[0..termCredits?length-2] /]
        [/#if]
        [#list termCredits?split(",") as credit]
        [#assign xxCreditMap = xxCreditMap +{i?string: (credit?number + (xxCreditMap[i?string]!0))}]
        [#assign i=i+1]
        [/#list]
        [#assign xxTotalCredits=xxTotalCredits+courseGroup.credits/]
      [/#if]
    [/#list]

    [#list bxllCreditMap?keys as k]
      [#assign bxllTotalCredits =bxllTotalCredits + (bxllCreditMap[k]!0) ]
    [/#list]
    [#list sxsjCreditMap?keys as k]
      [#assign sxsjTotalCredits =sxsjTotalCredits + (sxsjCreditMap[k]!0) ]
    [/#list]
    [#assign totalCredits=bxllTotalCredits+xxTotalCredits+sxsjTotalCredits/]

<table border="0" width="100%" align="center">
    <tr>
        <td align="center">
            <table id="creditAllocationTable${plan.id}" name="creditAllocationTable${plan.id}" class="planTable"  style="font-size:12px;font-family:宋体;vnd.ms-excel.numberformat:@" width="95%">
                [#assign maxTerm=plan.termsCount /]
                <thead>
                    <tr align="center">
                        <td rowspan="2" colspan="2" width="30%"></td>
                        [#assign total_term_credit={} /]
                        [#list 1..maxTerm as i ]
                            [#assign total_term_credit=total_term_credit + {i:0} /]
                            <td width="[#if maxTerm?exists&&maxTerm!=0]${40/maxTerm}[#else]4[/#if]%" rowspan="2" ><p align="center">${i}</p></td>
                        [/#list]
                        <td colspan="3"  width="30%">合计</td>
                    </tr>
                    <tr>
                    [#list ["学分","学时","比例"] as n]
                      <td width="10%" ><p align="center">${n}</p></td>
                    [/#list]
                    </tr>
                </thead>
                <tbody>
                    <tr align="center">
                        <td rowspan="2"  width="10%">理论教学</td>
                        <td width="20%">必修课</td>
                         [#list 1..maxTerm as i]
                          <td class="credit_hour">
                            ${bxllCreditMap[i?string]!}
                          </td>
                        [/#list]
                        <td class="credit_hour">${bxllTotalCredits}</td>
                        <td class="credit_hour">${bxllTotalCreditHour}</td>
                        <td rowspan="2" class="credit_hour">
                          ${(((bxllTotalCreditHour+xxTotalCredits*18)*1.00/(totalCredits*18))*100)?string(".00")}%
                        </td>
                    </tr>
                    <tr align="center">
                        <td width="20%">选修课</td>
                        [#list 1..maxTerm as i]
                          <td class="credit_hour">
                            [#if (xxCreditMap[i?string]!0)>0]${xxCreditMap[i?string]}[/#if]
                          </td>
                        [/#list]
                        <td class="credit_hour">${xxTotalCredits}</td>
                        <td class="credit_hour">${xxTotalCredits*18}</td>
                    </tr>
                    <tr align="center">
                        <td rowspan="2"  width="10%">实践教学</td>
                        <td   width="20%">实验，上机</td>
                        [#list 1..maxTerm as i]
                          <td class="credit_hour">&nbsp;</td>
                        [/#list]
                        <td class="credit_hour">&nbsp;</td>
                        <td class="credit_hour">${sysjTotalCreditHour}</td>
                        <td rowspan="2" class="credit_hour">
                        ${(((sysjTotalCreditHour+sxsjTotalCredits*18)*1.00/(totalCredits*18))*100)?string(".00")}%
                        </td>
                    </tr>
                    <tr align="center">
                        <td width="20%">实习，设计</td>
                        [#list 1..maxTerm as i]
                          <td class="credit_hour">
                            ${sxsjCreditMap[i?string]!}
                          </td>
                        [/#list]
                        <td class="credit_hour">${sxsjTotalCredits }</td>
                        <td class="credit_hour">${sxsjTotalCredits *18}</td>
                    </tr>
                    <tr align="center">
                        <td colspan="2"  >合计</td>
                        [#list 1..maxTerm as i]
                          <td class="credit_hour">&nbsp;</td>
                        [/#list]
                        <td class="credit_hour">${totalCredits}</td>
                        <td class="credit_hour">${totalCredits*18}</td>
                        <td class="credit_hour">100%</td>
                    </tr>
                </tbody>
            </table>
        </td>
    </tr>
</table>
