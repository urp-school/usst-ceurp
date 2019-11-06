[#ftl][#assign pt = 10.5/][#assign px = 12 / 9 * pt/]
[#assign td_width = "15mm"]
[@b.head]
  <style>
    body {
      text-align: center;
    }

    div.report-frame {
      [#-- max-width: 297mm; --]
    }

    div.report {
      padding: 0px;
      
      text-align: center;

      font-family: 宋体;
      font-size: ${pt}pt;
    }

    .report-title {
      font-size: 22pt;
      font-weight: bold;
      width: 100%;
    }

    table.reportTable {
      border-width: 1px;
      border-style: solid;
      border-color: black;

      min-width: 100%;
    }

    table.reportTable td {
      border-width: 1px;
      border-style: solid;
      border-color: black;

      width: ${td_width};

      word-break: break-all;
    }

    [#if pt lte 8]
    span.px {
      display: inline-block;
      -webkit-transform: scale(${ px / 12 });
    }
    [/#if]
  </style>
[/@]
  [@b.toolbar title="班级课程表" id="bar"]
    bar.addPrint();
    bar.addClose();
  [/@]
  [#function courseInfo squad, weekTime, index]
    [#local session = (courseTableMap[squad.id?string].sessionMap[weekTime.weekday.name + "|" + weekTime.beginAt][index])!"--"/]
    [#if session != "--"]
      [#local weeks = digestor.digest(session, ":weeks")?trim/]
      [#local info = session.clazz.course.name + "<br>" + session.clazz.schedule.weekHours + "×" + session.clazz.schedule.weeks?default(0) + ("(" + weeks + "周)<br>")?if_exists + session.clazz.teacherNames + "<br>"/]
      [#list session.rooms as room][#local info = info + (room_index gt 0)?string(",", "") + ((room.roomType.name)!) + room.name/][/#list]
    [/#if]
    [#return info/]
  [/#function]
  [#assign div_report_style]min-width: calc(${weekTimes?size + 1} * ${td_width} + 30mm)[/#assign]
  <div class="report-frame">
    [#if weekTimes?size gt 0]
    [#assign row = 5/]
    <div class="report" style="${div_report_style}">
      [#list squades?sort_by(["code"]) as squad]
        [#if squad_index % row == 0]
          [#if squad_index gt 0]
    </div>
    <div style="PAGE-BREAK-AFTER: always"></div>
    <div class="report" style="${div_report_style}">
          [/#if]
      <div class="report-title">上海理工大学继续教育学院课程表</div>
      <table class="reportTable" align="center">
        <tr>
          <td style="text-align: right; padding-right: 5px; width: 10%; border-bottom-width: 0px"><span class="px">上课时间</span></td>
          [#list weekTimes as weekTime]<td><span class="px">${weekTime.weekday.name}[#if weekTime.beginAt.hour lt 12]上午[#elseif weekTime.beginAt.hour lt 18]下午[#else]晚上[/#if]</span></td>[/#list]
        </tr>
        <tr>
          <td style="text-align: left; padding-left: 5px; border-top-width: 0px"><span class="px">班级</span></td>
          [#list weekTimes as weekTime]<td><span class="px">${weekTime.beginAt}－${weekTime.endAt}</span></td>[/#list]
        </tr>
        [/#if]
        [#assign max = courseTableMap[squad.id?string].max/]
        [#assign rowspan=max /]
        [#if courseTableMap[squad.id?string].noScheduled?size>0]
          [#assign rowspan=rowspan+1 /]
        [/#if]
        [#list 1..max as i]
        <tr>
          [#if 1 == i]<td rowspan="${rowspan}"><span class="px">${squad.name}<br>${squad.level.name}<br>${squadStdCounts.get(squad)}人</span></td>[/#if]
          [#list weekTimes as weekTime]
          <td><span class="px">${courseInfo(squad, weekTime, i - 1)!}</span></td>
          [/#list]
        </tr>
        [/#list]
        [#if rowspan>max]
        <tr>
          <td colspan="${weekTimes?size}">
          [#list courseTableMap[squad.id?string].noScheduled as clazz]
          ${clazz.course.name}${clazz.schedule.weeks}周[#list clazz.teachers as t]&nbsp;${t.name}[/#list][#if clazz_has_next]&nbsp;[/#if]
           [/#list]
          </td>
        </tr>
       [/#if]
        [#if squad_index % row == row - 1]
      </table>
        [/#if]
      [/#list]
    </div>
    [#else]
    <div>当前所有班级没有对应的课程安排。</div>
    [/#if]
  </div>
[@b.foot/]
