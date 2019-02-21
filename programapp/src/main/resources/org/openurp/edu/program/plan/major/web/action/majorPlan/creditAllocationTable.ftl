[#ftl]
<div style="text-indent: 2em;"><p style="color:#00108c;font-weight:bold;font-size:10pt;text-align:left;">七.教学环节设置及学分分配</p></div>
[#assign maxTerm = plan.termsCount /]
[#if Parameters['term']??]
[#assign term = Parameters['term']]
[/#if]
[#include "../../../../ftllib/planFunctions.ftl" /]
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
                        <td   width="20%">必修课</td>
                        [#assign bxTotalCredits = 0]
                        [#list 1..maxTerm as i]
                          <td class="credit_hour">
                            [#assign bxCredits = 0]
                            [#list plan.topCourseGroups! as courseGroup]
                              [#list courseGroup.planCourses as planCourse]
                                [#if courseGroup.compulsory && !((planCourse.course.name)?contains("课程设计")) && !((planCourse.course.name)?contains("毕业论文")) && !((planCourse.course.name)?contains("实习"))]
                                  [#if planCourse.terms.contains(i)]
                                    [#assign bxCredits = bxCredits + planCourse.course.credits]
                                  [/#if]
                                [/#if]
                              [/#list]
                            [/#list]
                            [#if bxCredits != 0]${bxCredits}[#else]&nbsp;[/#if]
                            [#assign bxTotalCredits = bxTotalCredits+bxCredits]
                          </td>
                        [/#list]
                        <td class="credit_hour">${bxTotalCredits }</td>
                        <td class="credit_hour">
                            [#assign bxllTotalCreditHour = 0]
                            [#list plan.topCourseGroups! as courseGroup]
                              [#list courseGroup.planCourses as planCourse]
                                [#if courseGroup.compulsory && !((planCourse.course.name)?contains("课程设计")) && !((planCourse.course.name)?contains("毕业论文")) && !((planCourse.course.name)?contains("实习"))]
                                  [#if planCourse.course.getHourById(1) ??]
                                    [#assign bxllTotalCreditHour = bxllTotalCreditHour + planCourse.course.getHourById(1)]
                                  [/#if]
                                [/#if]
                              [/#list]
                            [/#list]
                            ${bxllTotalCreditHour }
                        </td>
                        <td rowspan="2" class="credit_hour">&nbsp;</td>
                    </tr>
                    <tr align="center">
                        <td width="20%">选修课</td>
                        [#list plan.topCourseGroups! as courseGroup]
                          [#if !courseGroup.compulsory]
                            [@courseGroupCreditInfo courseGroup /]
                          [/#if]
                        [/#list]
                        <td class="credit_hour">
                          [#list plan.topCourseGroups! as courseGroup]
                            [#if !courseGroup.compulsory]${courseGroup.credits }[/#if]
                          [/#list]
                        </td>
                        <td class="credit_hour">
                          [#list plan.topCourseGroups! as courseGroup]
                            [#if !courseGroup.compulsory]${courseGroup.credits*18 }[/#if]
                          [/#list]
                        </td>
                    </tr>
                    <tr align="center">
                        <td rowspan="2"  width="10%">实践教学</td>
                        <td   width="20%">实验，上机</td>
                        [#list 1..maxTerm as i]
                          <td class="credit_hour">&nbsp;</td>
                        [/#list]
                        <td class="credit_hour">&nbsp;</td>
                        <td class="credit_hour">
                            [#assign sssjTotalCreditHour = 0]
                            [#list plan.topCourseGroups! as courseGroup]
                              [#list courseGroup.planCourses as planCourse]
                                  [#if planCourse.course.getHourById(2) ?? || planCourse.course.getHourById(3)?? ]
                                    [#assign sssjTotalCreditHour = sssjTotalCreditHour + planCourse.course.getHourById(2)?default(0) + planCourse.course.getHourById(3)?default(0)]
                                  [/#if]
                              [/#list]
                            [/#list]
                            ${sssjTotalCreditHour }
                        </td>
                        <td rowspan="2" class="credit_hour">&nbsp;</td>
                    </tr>
                    <tr align="center">
                        <td width="20%">实习，设计</td>
                        [#list 1..maxTerm as i]
                          <td class="credit_hour">
                            [#assign sxTotalCredits = 0]
                            [#list plan.topCourseGroups! as courseGroup]
                              [#list courseGroup.planCourses as planCourse]
                              [#if (planCourse.course.name)?contains("课程设计") || (planCourse.course.name)?contains("毕业论文") || (planCourse.course.name)?contains("实习")]
                                [#if planCourse.terms?exists && (","+planCourse.terms+",")?contains(","+i+",")]
                                  ${(planCourse.course.credits)?if_exists}[#else][/#if]
                                  [#assign sxTotalCredits = sxTotalCredits + planCourse.course.credits]
                                [/#if]
                              [/#list]
                            [/#list]
                          </td>
                        [/#list]
                        <td class="credit_hour">${sxTotalCredits }</td>
                        <td class="credit_hour">${sxTotalCredits *18}</td>
                    </tr>
                    <tr align="center">
                        <td colspan="2"  >合计</td>
                        [#list 1..maxTerm as i]
                          <td class="credit_hour">&nbsp;</td>
                        [/#list]
                        <td class="credit_hour">
                          [#assign TotalCredits = 0]
                          [#list plan.topCourseGroups! as courseGroup]
                              [#assign TotalCredits = TotalCredits+ courseGroup.credits]
                          [/#list]
                          ${ TotalCredits}
                        </td>
                        <td class="credit_hour">${ TotalCredits*18}</td>
                        <td class="credit_hour">&nbsp;</td>
                    </tr>
                </tbody>
            </table>
        </td>
    </tr>
</table>
