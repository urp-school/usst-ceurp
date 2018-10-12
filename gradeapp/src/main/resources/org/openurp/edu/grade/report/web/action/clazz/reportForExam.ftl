[#ftl]
[@b.head]
  <style>
    .report {
      width: 100%;
      
      margin-left: auto;
      margin-right: auto;
      
      font-family: 宋体;
      font-size: 12pt;
      text-align: center;
      vertical-align: middle;
    }
    
    .report > .report-top {
      font-size: 10pt;
    }
    
    .report > .report-header {
      width: 100%;
      
      padding-top: 5px;
      padding-bottom: 5px;
      
      font-family: 黑体;
      font-size: 16pt;
    }
    
    .report > .report-header * {
      ;
    }
    
    .report .report-table-row {
      height: 50px;
    }
    .report .report-table-half-row {
      height: 25px;
    }
    .report .report-table-min-row {
      height: 2px;
    }
    .report .report-table-bigrow {
      height: 175px;
      vertical-align: top;
    }
    
    .report span {
      display: inline-block;
    }
    
    .report span.underline {
      border-bottom-width: 1px;
      border-bottom-style: solid;
      border-bottom-color: black;
    }
    .report table.listTable {
      font-family: 宋体;
      border-style:solid;
      border-width:2px;
      border-color:black;
      vertical-align: middle;
      font-style: normal;
      text-align: center;
    }
    .report table.listTable td{
      padding-left: 2px;
      padding-right: 2px;
      border-style:solid;
      border-width:1px;
      border-color:black;
    }
    .report table.listTable td .examMode {
      width: 100%;
      border-width: 0px;
    }
    .report table.listTable td .examMode .examMode-item {
      border-width: 0px;
    }
    .report table.listTable td .examMode .examMode-item .examMode-item-checkbox {
      display: inline-block;
      width: 15px;
      height: 15px;
      border-width: 1px;
      border-style: solid;
      border-color: black;
    }
    .report table.listTable td .examMode .examMode-item .examMode-item-label {
      display: inline-block;
      border-width: 0px;
    }
    .report table.listTable td table.report-detail {
      width: 100%;
      border-width: 0px;
    }
    .report table.listTable td table.report-detail tr:first-child {
      ;
    }
    .report table.listTable td table.report-detail tr:first-child > td {
      border-width: 0px;
    }
    .report table.listTable td table.report-detail td {
      border-left-width: 0px;
      border-bottom-width: 0px;
    }
    
    .report .report-foot {
      width: 60%;
      margin-left: 40%;
    }
    .report .report-foot > .report-foot-row {
      width: 100%;
    }
    .report .report-foot > .report-foot-row > .report-foot-row-td {
      display: inline-block;
      width: 50%;
      height: 30px;
      padding-top: 15px;
      float: left;
    }
    .report .report-foot > .report-foot-row > .report-foot-row-td.report-foot-row-left {
      text-align: start;
    }
    .report .report-foot > .report-foot-row > .report-foot-row-td.report-foot-row-right {
      ;
    }
  </style>
[/@]
  [@b.toolbar title="课程试卷分析表"]
    bar.addPrint();
    bar.addClose();
  [/@]
  <div class="report">[#assign top_ul_style = "width: calc((195mm - 80mm) / 2);"/]
    <div class="report-top"><span class="underline" style="${top_ul_style}"><br></span><span>上海理工大学继续教育学院成人高等学历教育<span class="underline" style="${top_ul_style}"><br></span></div>
    <div class="report-header"><span>20</span><span class="underline" style="width: 30px;height: 18pt;"><br></span><span>季</span><span class="underline" style="width: 30px;height: 18pt;"><br></span><span>学期</span><span class="underline" style="width: 200px;height: 18pt;"><br></span><span>课程试卷分析表</span></div>
    <table class="listTable" align="center">
      <tr class="c">
        <td><span style="letter-spacing: 3px">教学</span>站</td>
        <td width="130px"></td>
        <td>课程代码</td>
        <td width="120px"></td>
        <td>课程序号</td>
        <td width="90px"></td>
        <td>考试形式</td>
        <td width="100px">
          <table class="examMode" align="center">
            <tr class="examMode-item">
              <td class="examMode-item-checkbox"></td>
              <td class="examMode-item-label">开卷</td>
            </tr>
            <tr class="examMode-item">
              <td class="examMode-item-checkbox"></td>
              <td class="examMode-item-label">闭卷</td>
            </tr>
          </table>
        </td>
      </tr>
      <tr class="report-table-row">
        <td><span style="letter-spacing: 3px">教学</span>班</td>
        <td colspan="7"></td>
      </tr>
      <tr class="report-table-min-row">
        <td colspan="8"></td>
      </tr>
      <tr>
        <td colspan="8" style="padding: 0px">
          <table class="report-detail">
            <tr class="report-table-row">
              <td colspan="12">成绩分析</td>
            </tr>
            <tr class="report-table-half-row">
              <td rowspan="2" width="60px"></td>
              <td rowspan="2">总人数</td>
              <td rowspan="2" width="70px">实考</td>
              <td rowspan="2" width="70px">缺考</td>
              <td colspan="8" style="font-size: 10pt">考试成绩分布</td>
            </tr>
            <tr class="report-table-half-row" style="font-size: 10pt">
              <td width="54px">0-59</td>
              <td width="54px">60-69</td>
              <td width="54px">70-79</td>
              <td width="54px">80-89</td>
              <td width="54px">90-100</td>
              <td width="54px">最高分</td>
              <td width="54px">最低分</td>
              <td width="54px">平均分</td> 
            </tr>
            <tr class="report-table-row">
              <td>人数</td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
            </tr>
            <tr class="report-table-row">
              <td>比例</td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
              <td></td>
            </tr>
          </table>
        </td>
      </tr>
      <tr class="report-table-min-row">
        <td colspan="8"></td>
      </tr>
      <tr class="report-table-row">
        <td colspan="8">综合分析</td>
      </tr>
      <tr class="report-table-bigrow">
        <td colspan="8">命题分析（试卷难度、覆盖面和试卷题型等适宜情况）</td>
      </tr>
      <tr class="report-table-bigrow">
        <td colspan="8">结果分析（教学方法、内容选取和学生掌握等情况）</td>
      </tr>
      <tr class="report-table-bigrow">
        <td colspan="8">措施与方法（教学成效、教学不足和改进意见）</td>
      </tr>
    </table>
    <table align="center" width="708px">
      <tr>
        <td>
          <div class="report-foot">
            <div class="report-foot-row">
              <div class="report-foot-row-td report-foot-row-left"><span style="letter-spacing: 6pt">指导教师签</span>名：</div>
              <div class="report-foot-row-td report-foot-row-right"><span>20</span><span style="width: 25px"></span><span>年</span><span style="width: 25px"></span><span>月</span><span style="width: 25px"></span><span>日</span></div>
            </div>
            <div class="report-foot-row">
              <div class="report-foot-row-td report-foot-row-left"><span style="margin-right: 6pt">教学点负责人</span>签名：</div>
              <div class="report-foot-row-td report-foot-row-right"><span>20</span><span style="width: 25px"></span><span>年</span><span style="width: 25px"></span><span>月</span><span style="width: 25px"></span><span>日</span></div>
            </div>
          </div>
          <div style="margin-top: 75px; text-align: start; font-size: 10pt">注：此表填写后，与试卷、成绩单一并归档到教学点。</div>
        </td>
      </tr>
    </table>
  </div>
[@b.foot/]