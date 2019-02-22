[#ftl]
[#macro i18nName(entity)][#if locale.language?index_of("en")!=-1][#if entity.enName?if_exists?trim==""]${entity.name?if_exists}[#else]${entity.enName?if_exists}[/#if][#else][#if entity.name?if_exists?trim!=""]${entity.name?if_exists}[#else]${entity.enName?if_exists}[/#if][/#if][/#macro]
[#--
/*********************************************************
 * 下面的macro是在majorPlanSearch.action的info里面用的
 *********************************************************/
--]

[#include "planBaseFunctions.ftl" /]
[#-- 获得一个课程组所应该colspan多少 --]
[#function fenleiSpan maxFenleiSpan group]
    [#if isLeaf(group)]
        [#-- 2 是因为需要跨 课程代码，课程名称两列 --]
        [#if group.parent??]
            [#if (!group.children?? || group.children?size == 0) && myCurrentLevel(group)!=teachPlanLeafLevels && fenleiSpan(maxFenleiSpan,group.parent)==1]
                [#return mustSpan + teachPlanLeafLevels - myCurrentLevel(group)/]
            [#else]
                [#return mustSpan/]
            [/#if]
        [#else]
            [#return mustSpan + maxFenleiSpan /]
        [/#if]
    [#else]
        [#local all_children_leaf =  true /]
        [#list group.children! as c]
            [#if !isLeaf(c)][#local all_children_leaf = false /][#break][/#if]
        [/#list]
        [#if all_children_leaf]
            [#return maxFenleiSpan - myCurrentLevel(group) + 1/]
        [#else]
            [#return 1/]
        [/#if]
    [/#if]
[/#function]

[#-- 获得自己和自己的祖宗所使用的分类一栏的colspan总和 --]
[#function HierarchyFenleiSpanSum maxFenleiSpan group]
    [#if !group.parent??]
        [#return fenleiSpan(maxFenleiSpan, group) /]
    [/#if]
    [#return fenleiSpan(maxFenleiSpan, group) + HierarchyFenleiSpanSum(maxFenleiSpan, group.parent) /]
[/#function]

[#-- 获得从树的顶端到自己的一条链 --]
[#function getHierarchyTree group]
    [#if group.parent??]
        [#return getHierarchyTree(group.parent) + [group] /]
    [/#if]
    [#return [group] /]
[/#function]

[#-- 把自己的向上的一条树统统画出来, eg. 爷爷/儿子/孙子 --]
[#macro drawAllAncestor courseGroup]
    [#local tree = getHierarchyTree(courseGroup) /]
    [#list tree as node]
        [#if (!node.parent??)]
            [#if  (node.children?size < 1) && (node.planCourses?size < 1)]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}">[@i18nName node.courseType/]</td>
            [/#if]
            [#if (node.children?size < 1) && (node.planCourses?size > 0)]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}" width="${fenleiWidth * maxFenleiSpan}px">[@i18nName node.courseType/]</td>
            [/#if]
            [#if (node.children?size > 0) ]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}" width="2%">[@i18nName node.courseType/]</td>
            [/#if]
        [#else]
            [#if (node.children?size < 1) && (node.planCourses?size < 1)]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}">[@i18nName node.courseType/]</td>
            [/#if]
            [#if (node.children?size < 1) && (node.planCourses?size > 0)]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}" width="2%">
                    [@i18nName node.courseType/]
                </td>
            [/#if]
            [#if (node.children?size > 0)]
                <td class="group" colspan="${fenleiSpan(maxFenleiSpan, node)}" width="2%">[@i18nName node.courseType/]</td>
            [/#if]
        [/#if]
    [/#list]
[/#macro]

[#-- 计划课程的一格一格的学分信息 --]
[#macro planCourseCreditInfo planCourse]
    [#list 1..maxTerm as i]
            <td class="credit_hour">
                [#if planCourse.terms?exists && (","+planCourse.terms+",")?contains(","+i+",")]${(planCourse.course.credits)?default(0)}[#else]&nbsp;[/#if]
            </td>
    [/#list]
[/#macro]

[#-- 课程组的一格一格的学分信息 --]
[#macro courseGroupCreditInfo courseGroup]
    [#local i = 1 /]
    [#if  courseGroup.termCredits=="*"]
        [#list i..maxTerm as t]<td class="credit_hour">&nbsp;</td>[/#list]
    [#else]
        [#local termCredits= courseGroup.termCredits/]
        [#if termCredits?starts_with(",")]
            [#local termCredits= termCredits[1..termCredits?length-1] /]
        [/#if]
        [#if termCredits?ends_with(",")]
            [#local termCredits= termCredits[0..termCredits?length-2] /]
        [/#if]
        [#list termCredits[0..termCredits?length-1]?split(",") as credit]
          [#if (i<=maxTerm)]
            <td class="credit_hour">[#if credit!="0"]${credit}[#else]&nbsp;[/#if]</td>
            [#if !courseGroup.parent??]
                [#local current_totle=total_term_credit[i?string]!(0) /]
                [#assign total_term_credit=total_term_credit + {i:current_totle+credit?number} /]
                [#local i = i + 1 /]
            [/#if]
          [/#if]
        [/#list]
    [/#if]
[/#macro]
[#-- 计划课程的一格一格的周课时信息 --]
[#macro planCourseWeekHoursInfo planCourse]
    [#list 1..maxTerm as i]
        <td class="credit_hour">[#if planCourse.terms?exists && (","+planCourse.terms+",")?contains(","+i+",")]${(planCourse.course.weekHours)?if_exists}[#else]&nbsp;[/#if]</td>
    [/#list]
[/#macro]

[#assign kksj_weeks=0][#--课程设计周数 --]
[#assign bysj_weeks=0][#--毕业设计周数 --]
[#assign total_credit_hours=0]
[#assign total_1_hours=0][#--分类课时1 --]
[#assign total_2_hours=0][#--分类课时1 --]
[#assign total_3_hours=0][#--分类课时1 --]

[#-- 需要完善，画出一个课程组 --]
[#macro drawGroup courseGroup courseTermInfoMacro groupTermInfoMacro]

[#local group_kksj_weeks=0][#--本组课程设计周数 --]
[#local group_bysj_weeks=0][#--本组毕业设计周数 --]

[#assign courseCount = 0 /]
    [#if isLeaf(courseGroup)]
        <tr>
            [@drawAllAncestor courseGroup /]
            <td class="credit_hour">${courseGroup.credits}</td>
            <td class="credit_hour">&nbsp;</td>
            <td class="credit_hour">&nbsp;</td>
            <td class="credit_hour">&nbsp;</td>
            <td class="credit_hour">&nbsp;</td>
            <td class="credit_hour">&nbsp;</td>
            <td class="credit_hour">&nbsp;</td>
            [@groupTermInfoMacro courseGroup /]
            <td>&nbsp;</td>
        </tr>
    [#else]
        [#list courseGroup.planCourses?sort_by(['course','code'])?sort_by(['terms','value']) as planCourse]
           [#if !(term??) || term?? && term?length=0 ||term?? && planCourse.terms.contains(term?number)]
            [#assign courseCount = courseCount + 1]
            <tr>
            [@drawAllAncestor courseGroup /]

            [#local exists_nonleaf_child = false /]
            [#list courseGroup.children as c]
                [#if !isLeaf(c) ][#local exists_nonleaf_child=true /][#break][/#if]
            [/#list]
            [#if exists_nonleaf_child]
                <td class="group" colspan="${maxFenleiSpan - myCurrentLevel(courseGroup)}">&nbsp;</td>
            [/#if]

            <td style="text-align: center;">${planCourse.course.code!}</td>
            <td class="course">&nbsp;${courseCount}&nbsp;[@i18nName planCourse.course/]</td>
            <td class="credit_hour">${(planCourse.course.credits)?default(0)}</td>
            <td class="credit_hour">${(planCourse.course.creditHours)?default(0)}</td>
            <td class="credit_hour">${(planCourse.course.getHourById(1))!}</td>
            <td class="credit_hour">${(planCourse.course.getHourById(2))!}</td>
            <td class="credit_hour">${(planCourse.course.getHourById(3))!}</td>
            <td class="credit_hour">
              [#if (planCourse.course.name)?contains("课程设计")]
                ${(planCourse.course.weeks)!}周
                [#local group_kksj_weeks=group_kksj_weeks + ((planCourse.course.weeks)!0)]
              [/#if]
            </td>
            <td class="credit_hour">
              [#if (planCourse.course.name)?contains("毕业论文") || (planCourse.course.name)?contains("毕业设计")]
                ${(planCourse.course.weeks)! }周
                [#local group_bysj_weeks=group_bysj_weeks + ((planCourse.course.weeks)!0)]
              [/#if]
            </td>
            [@courseTermInfoMacro planCourse /]
          </tr>
         [/#if]
        [/#list]
        [#list courseGroup.children! as child]
            [@drawGroup child courseTermInfoMacro groupTermInfoMacro/]
        [/#list]
        <tr>
            [@drawAllAncestor courseGroup /]
            <td colspan="${mustSpan + maxFenleiSpan - HierarchyFenleiSpanSum(maxFenleiSpan, courseGroup)}" class="credit_hour summary">
                [#if courseGroup.compulsory]${b.text("attr.creditSubtotal")}[#else]
                <font color="#1F3D83">
                  [#if courseGroup.credits=0]应修门数[#else]${b.text("courseGroup.credits")}[/#if]
                </font>
                [/#if]
            </td>
            <td class="credit_hour summary">
              [#if courseGroup.compulsory]${courseGroup.credits}
              [#else]
                <font color="#1F3D83">
                [#if courseGroup.credits=0]${courseGroup.courseCount}门[#else]${courseGroup.credits}[/#if]
                </font>
              [/#if]
            </td>
            [#if courseGroup.compulsory]
            <td class="credit_hour">
              [#assign totalCreditHours = 0]
              [#list courseGroup.planCourses as planCourse]
                [#assign totalCreditHours = totalCreditHours + planCourse.course.creditHours]
              [/#list]
              [#assign total_credit_hours = total_credit_hours + totalCreditHours/]
              [#if totalCreditHours>0]${totalCreditHours}[/#if]
            </td>
            <td class="credit_hour">
              [#assign totalCreditHours = 0]
              [#list courseGroup.planCourses as planCourse]
                  [#assign totalCreditHours = totalCreditHours + (planCourse.course.getHourById(1)?default(0))]
              [/#list]
              [#assign total_1_hours = total_1_hours + totalCreditHours/]
              [#if totalCreditHours>0]${totalCreditHours}[/#if]
            </td>
            <td class="credit_hour">
              [#assign totalCreditHours = 0]
              [#list courseGroup.planCourses as planCourse]
                  [#assign totalCreditHours = totalCreditHours + (planCourse.course.getHourById(2)?default(0))]
              [/#list]
              [#assign total_2_hours = total_2_hours + totalCreditHours/]
              [#if totalCreditHours>0]${totalCreditHours}[/#if]
            </td>
            <td class="credit_hour">
              [#assign totalCreditHours = 0]
              [#list courseGroup.planCourses as planCourse]
                  [#assign totalCreditHours = totalCreditHours + (planCourse.course.getHourById(3)?default(0))]
              [/#list]
              [#assign total_3_hours = total_3_hours + totalCreditHours/]
              [#if totalCreditHours>0]${totalCreditHours}[/#if]
            </td>
            [#else]
            <td class="credit_hour">${(courseGroup.credits)*18}</td>
            <td class="credit_hour">
            ${(courseGroup.credits)*18}
            [#assign total_credit_hours = total_credit_hours + (courseGroup.credits)*18/]
            [#assign total_1_hours = total_1_hours + (courseGroup.credits)*18/]
            </td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            [/#if]
            <td class="credit_hour">[#if group_kksj_weeks>0]${group_kksj_weeks}周[#else]&nbsp;[/#if]</td>
            <td class="credit_hour">[#if group_bysj_weeks>0]${group_bysj_weeks}周[#else]&nbsp;[/#if]</td>
            [@groupTermInfoMacro courseGroup /]
        </tr>
    [/#if]

    [#if !(courseGroup.parent??)]
      [#assign kksj_weeks=kksj_weeks + group_kksj_weeks]
      [#assign bysj_weeks=bysj_weeks + group_bysj_weeks]
    [/#if]
[/#macro]

[#-- 培养计划中课程组的层次, 默认为1层 --]
[#assign teachPlanLevels = planMaxDepth(plan) /]
[#if teachPlanLevels == 0]
    [#assign teachPlanLevels = 1 /]
[/#if]

[#-- 培养计划中叶子节点的最深层次, 默认为1层 --]
[#assign teachPlanLeafLevels = planLeafMaxLevel(plan) /]
[#if teachPlanLeafLevels == 0]
    [#assign teachPlanLeafLevels = 1 /]
[/#if]

[#-- 分类一栏的colspan --]
[#assign maxFenleiSpan = teachPlanLeafLevels - 1]
[#if maxFenleiSpan <= 0]
    [#assign maxFenleiSpan = 1 /]
[/#if]

[#-- 有时候必须跨的列数，在这里是课程名称和课程代码两列 --]
[#assign mustSpan = 2/]

[#assign courseCount = 0 /]
[#assign fenleiWidth = 10 /]

[#macro mergeCourseTypeCell plan t_planLevels bottomrows]
    function mergeCourseTypeCell(tableId) {
        var table = document.getElementById(tableId)
        for(var x = ${t_planLevels} - 1; x >= 0 ; x--) {
            var content = '';
            var firstY = -1;
            for(var y = 2; y < table.rows.length - ${bottomrows}; y++) {
                if(table.rows[y] == undefined || table.rows[y].cells[x] == undefined) {
                    continue;
                }
                if(content == table.rows[y].cells[x].innerHTML && table.rows[y].cells[x].className == 'group') {
                    table.rows[y].deleteCell(x);
                    table.rows[firstY].cells[x].rowSpan++;
                }
                else {
                    content = table.rows[y].cells[x].innerHTML;
                    // 如果是纯数字或‘学分小计’则不合并
                    if(table.rows[y].cells[x].className != 'group') {
                        content = '';
                    }
                    firstY = y;
                }
            }
        }
    }
   mergeCourseTypeCell('planInfoTable${plan.id}');
[/#macro]

[#macro planSupTitle plan]
    状态：${plan.program.state.fullName}&nbsp;
    生效日期：${plan.program.beginOn?string('yyyy-MM-dd')}~${(plan.program.endOn?string('yyyy-MM-dd'))!}&nbsp;
    最后修改时间：${(plan.program.updatedAt?string('yyyy-MM-dd HH:mm:ss'))!}
[/#macro]

[#macro planTitle plan]
${plan.program.level.name}&nbsp;${plan.program.stdType.name}&nbsp;${plan.program.department.name}&nbsp;${plan.program.major.name}专业
<br>${(plan.program.direction.name + "&nbsp;")!}${b.text('entity.program')}&nbsp;(${plan.program.grade})
[/#macro]
