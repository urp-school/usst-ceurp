[#ftl]
[#macro i18nName(entity)][#if locale.language?index_of("en")!=-1][#if entity.enName?if_exists?trim==""]${entity.name?if_exists}[#else]${entity.enName?if_exists}[/#if][#else][#if entity.name?if_exists?trim!=""]${entity.name?if_exists}[#else]${entity.enName?if_exists}[/#if][/#if][/#macro]
[#include "../../../../ftllib/planFunctions.ftl" /]
[#if Parameters['toXLS']?exists]
    [#include "/template/excelHead.ftl"/]
    <link rel="stylesheet" type="text/css" href="${base}/static/css/plan.css" />
[#else]
    [@b.head /]
    <link rel="stylesheet" type="text/css" href="${base}/static/css/plan.css" />
    [#assign _params]${Parameters['params']!(flash['params']!)}[/#assign]
    [#assign backUrl]${Parameters['backUrl']!(flash['backUrl']!)}[/#assign]
    [#assign numericTerm=plan.numericTerm/]
    <body>
    [#assign planStyle="Default"]
    [#if numericTerm]
        [#if Parameters['style']??][#assign planStyle=Parameters['style']][/#if]
    [#else]
        [#assign planStyle="Simple"]
    [/#if]

    [@b.toolbar title=plan.program.name]
        [#if plan.program.state == UNSUBMITTED || plan.program.state == REJECTED]
            bar.addItem("提交审核",    "applyAudit()");
        [/#if]
        [#if numericTerm]
        [/#if]
        bar.addItem("${b.text("action.print")}","print_it()");
        bar.addItem("${b.text("action.export")}","exportToExcel('PrintA')");
        bar.addItem('返回', '_back()');
        function _back() {
        [#if backUrl?index_of('search') > 0]
            bg.form.submit(document._tmpForm, '${backUrl}?${_params}', 'planListFrame');
        [#else]
            bg.form.submit(document._tmpForm, '${backUrl}', 'planListFrame');
        [/#if]
        }
    [/@]

    <form name="_tmpForm" action="#" method="POST">
        <input type="hidden" name="params" value="${_params}" />
        <input type="hidden" name="backUrl" value="${backUrl}" />
    </form>
[/#if]

    [#assign maxTerm = plan.termsCount /]

    [#if !(Parameters['toXLS']?exists) && numericTerm]
        <table class="formTable" align="center" width="70%">
            <tr>
                <td class="darkColumn" width="20%">学期：</td>
                <td>
                    <select name="term" style="width:100px" onchange="queryTerm1(this.value);" >
                        <option value="">所有学期</option>
                        [#list 1..maxTerm as i]
                            <option value="${i}"[#if Parameters['term']?default("") == i?string] selected[/#if]>第${i}学期</option>
                        [/#list]
                    </select>
                </td>
            </tr>
        </table>
    [/#if]

<div id="PrintA" width="100%" align="center">
    <p style="color:#00108c;font-weight:bold;font-size:13pt;margin:0px 5px;">[@planTitle plan/]</p>
    [@ems.guard res="/programDoc"]
        [@b.div style="width:95%;" href="/programDoc!info?majorPlan.id=${plan.id}"][/@]
    [/@]
    [#include "../majorPlanSearch/planInfoTable${planStyle}.ftl"/]
</div>

<div style="width:100%;text-align:center;">
    <p style="color:#666666">[@planSupTitle plan/]</p>
</div>
<script type="text/javascript">
    function applyAudit() {
        if(!confirm("确认提交培养计划？计划一旦提交就不能修改。")) {
            return;
        }
        setSearchParams(document.planSearchForm);
        bg.form.submit(document.planSearchForm, 'majorPlan!applyAudit.action?planIds=${plan.id}', "planListFrame");
    }

    function print_it() {
        bg.form.submit(document._tmpForm, 'majorPlanSearch!print.action?planId=${plan.id}&style=${planStyle}', '_blank');
    }

    function getInfoWith(kind) {
        bg.form.submit(document._tmpForm, 'majorPlan!info.action?planId=${plan.id}&style=' + kind, 'planListFrame');
    }

    function queryTerm1(term) {
        bg.form.submit(document._tmpForm, "majorPlan!info.action?planId=${plan.id}&style=${planStyle}&term=" + term, 'planListFrame');
    }
</script>

[@b.foot /]
