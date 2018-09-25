[#ftl]
[@b.head/]
  [@b.toolbar title="班级课程表" id="courseTableTaskBar"]
    bar.addPrint();
    bar.addClose();
  [/@]

  [#assign width = "200px"/]
  [#assign height = "50px"/]

  <table class="gridtable" style="width: ${width}">
    <tr class="gridhead">
      <th width="${width}" style="text-align: right; padding-right: 5px; border-bottom-width: 0px">上课时间</th>
    </tr>
    <tr class="gridhead">
      <th style="text-align: left; padding-left: 5px">班级</th>
    </tr>
  </table>
[@b.foot/]
