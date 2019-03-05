[#ftl]
<div style="text-indent: 2em;"><p style="color:#00108c;font-weight:bold;font-size:10pt;text-align:left;">八.实践教学环节安排</p></div>
[#assign maxTerm = plan.termsCount /]
[#if Parameters['term']??]
[#assign term = Parameters['term']]
[/#if]
<table border="0" width="100%" align="center">
    <tr>
        <td align="center">
            <table id="practiceArrangeTable${plan.id}" name="practiceArrangeTable${plan.id}" class="planTable"  style="font-size:12px;font-family:宋体;vnd.ms-excel.numberformat:@" width="95%">
                [#assign maxTerm=plan.termsCount /]
                <thead>
                    <tr align="center">
                        <td rowspan="2" width="10%">序号</td>
                        <td rowspan="2" width="10%">课程代码</td>
                        <td rowspan="2" width="20%">课程名称或项目名称</td>
                        <td rowspan="2" width="10%">周数学分</td>
                        <td colspan="${maxTerm}" width="40%">各学期学分数</td>
                        <td rowspan="2" width="10%">备注</td>
                    </tr>
                    <tr>
                      [#assign total_term_credit={} /]
                      [#list 1..maxTerm as i ]
                          [#assign total_term_credit=total_term_credit + {i:0} /]
                          <td width="[#if maxTerm?exists&&maxTerm!=0]${40/maxTerm}[#else]4[/#if]%" rowspan="2" ><p align="center">${i}</p></td>
                      [/#list]
                    </tr>
                </thead>
                <tbody>
                [#assign courseCount = 0 /]
                [#list plan.topCourseGroups! as courseGroup]
                  [#list courseGroup.planCourses?sort_by(['course','code'])?sort_by(['terms','value']) as planCourse]
                    [#if planCourse.course.isPractical()]
                      [#assign courseCount = courseCount + 1]
                      <tr>
                        <td class="credit_hour">${courseCount }</td>
                        <td style="text-align: center;">${planCourse.course.code!}</td>
                        <td class="course">&nbsp;[@i18nName planCourse.course/]</td>
                        <td class="credit_hour">${(planCourse.course.credits)?default(0)}</td>
                        [#list 1..maxTerm as i]
                          <td class="credit_hour">[#if planCourse.terms?exists && (","+planCourse.terms+",")?contains(","+i+",")]${(planCourse.course.credits)?if_exists}[#else]&nbsp;[/#if]</td>
                        [/#list]
                        <td class="credit_hour">&nbsp;</td>
                      </tr>
                    [/#if]
                  [/#list]
                [/#list]
                </tbody>
            </table>
        </td>
    </tr>
</table>
