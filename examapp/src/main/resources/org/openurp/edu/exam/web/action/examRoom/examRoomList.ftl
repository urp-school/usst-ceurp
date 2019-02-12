[#ftl/]
[@b.head /]
[@b.grid items=examRooms! var="room" sortable="true"]
    [@b.gridbar]
      [#--var menuBar = bar.addMenu("设置主考", function() {
        var roomIds = bg.input.getCheckBoxValues("room.id");
        if (isBlank(roomIds)) {
          alert("请选择要设置主考老师的考场，谢谢!");
          return;
        }

        var form = document.roomListForm;
        form.action = "${base}/examRoom!examinerDistribution.action";
        form["room.ids"].value = roomIds;
        form.target = "contentFrame";
        bg.form.submit(form);
      }, "update.png");
      menuBar.addItem("按授课教师设置主考", function() {
        var roomIds = bg.input.getCheckBoxValues("room.id");
        if (isBlank(roomIds)) {
          alert("请选择要设置主考老师的考场，谢谢!");
          return;
        }

        var form = document.roomListForm;
        form.action = "${base}/examRoom!examinerDistributionByClazz.action";
        form["room.ids"].value = roomIds;
        form.target = "contentFrame";
        bg.form.submit(form);
      }, "update.png");
      --]
      var m =bar.addMenu("设置监考", function() {
        var roomIds = bg.input.getCheckBoxValues("room.id");
        if (isBlank(roomIds)) {
          alert("请选择要设置监考老师所代表考试安排的考场，谢谢!");
          return;
        }

        var form = document.roomListForm;
        form.action = "${base}/examRoom!invigilatorDistribution.action";
        form["room.ids"].value = roomIds;
        form.target = "contentFrame";
        bg.form.submit(form);
      }, "update.png", "选择要设置监考老师所代表考试安排的考场");
      function autoAssignInvigilator(){
         var form = action.getForm();
         var roomIds = bg.input.getCheckBoxValues("room.id");
        if (isBlank(roomIds)) {
          if(!confirm("确定自动指定查询范围内${examRooms.totalItems}考场的监考？")){
            return;
          }
        }else{
           if(!confirm("确定自动指定选中考场的监考？")){
             return;
           }
           bg.form.addInput(form,"room.ids",roomIds,"hidden");
        }
        action.method("assignInvigilator",null,null,true).func();
      }
      m.addItem("删除监考",action.multi('batchRemoveInvigilations',"确认删除？"));
      m.addItem("自动分配","autoAssignInvigilator()");

      var m3=bar.addMenu("打印签名表", "signature()", "action-print");
      m3.addItem("预览座位表", "seatReport()", "action-print");
      m3.addItem("考场情况记录表", function() {
        var examRoomIds = bg.input.getCheckBoxValues("room.id");
        if (isBlank(examRoomIds)) {
          alert("请选择一个或多个进行操作!");
          return;
        }
        var form = document.roomListForm;
        form["room.ids"].value = examRoomIds;
        bg.form.submit(form, "${b.url("!printExamSituation")}", "_blank");
      }, "action-print");

      function seatReport(){
        var examRoomIds = bg.input.getCheckBoxValues("room.id");
        if("" == examRoomIds) { alert("请选择一个或多个考试地点"); return; }
        window.open("examRoom!seatReport.action?examType.id=${Parameters["examType.id"]!}&examRoomIds="+examRoomIds);
      }
      function signature(){
        var examRoomIds = bg.input.getCheckBoxValues("room.id");
        if("" == examRoomIds) { alert("请选择一个或多个考试地点"); return; }
        window.open("examRoom!signature.action?examType.id=${Parameters["examType.id"]!}&examRoomIds="+examRoomIds);
      }

      bar.addItem("打印试卷贴", function() {
        var examRoomIds = bg.input.getCheckBoxValues("room.id");
        if (isBlank(examRoomIds)) {
          alert("请选择一个或多个进行操作!");
          return;
        }
        var form = document.roomListForm;
        form["room.ids"].value = examRoomIds;
        bg.form.submit(form, "examRoom!printPaperPosts.action", "_blank");
      }, "print.png");

      bar.addItem("${b.text("action.export")}", "exportData()");
      function exportData() {
        var form = document.roomSearchForm;
        bg.form.addInput(form, "keys", "room.campus.name,teachDepart.name,courseCodes,courseNames,stdCount,examOn,beginAt,endAt,room.name,examiner.user.name,invigilationNames");
        bg.form.addInput(form, "titles", "校区,开课院系,课程代码,课程名称,考生人数,考试日期,开始时间,结束时间,考试地点,主考,监考");
        bg.form.addInput(form,"fileName","考场安排信息");
        bg.form.submit(form,"${b.url('!export')}","_self")
      }

    [/@]
    [@b.row]
        [@b.boxcol/]
        [@b.col title="校区" width="8%" property="room.campus.name" /]
        [@b.col title="考试地点" width="9%" property="room.name"/]
        [@b.col title="考试时间" width="19%" sort="room.examOn,room.beginAt"][#if room.examOn??]${room.examOn?string("yy-MM-dd")} ${room.beginAt}~${room.endAt}[/#if][/@]
        [@b.col title="考生数" width="5%" property="stdCount"]${room.stdCount}[/@]
        [@b.col title="开课院系" width="6%" property="teachDepart.name"]
          [#if room.teachDepart.shortName??]${room.teachDepart.shortName}[#else]${room.teachDepart.name}[/#if]
        [/@]
        [@b.col title="院系 监考人" width="18%"]
        [#if room.invigilations?size < 2]<span style="color:red">*</span>[/#if]
          [#assign lastDepartName=""/]
          [#list room.invigilations?sort_by('chief')?reverse as invigilation]
            [#if lastDepartName!=invigilation.teacher.user.department.name]
              [#if lastDepartName?length>0],[/#if][#t/]
              ${invigilation.teacher.user.department.shortName!}&nbsp;[#t/]
              [#assign lastDepartName=invigilation.teacher.user.department.name/]
            [#else]
            &nbsp;[#t/]
            [/#if]${invigilation.teacher.user.name}[#t/]
          [/#list]
        [/@]
        [#if Parameters['examType.id'] = '2']
        [@b.col title="课程" width="31%"]
          [#assign courseStds =room.courseStds/]
          [#list courseStds?keys as c]
            ${c.name}${courseStds.get(c)?size}人
          [/#list]
        </span>
        [/@]
        [#else]
        [@b.col title="课程" width="36%"]
          [#list room.activities as activity]${activity.clazz.crn} ${activity.clazz.course.name}[#if activity_has_next]&nbsp;[/#if][/#list]
        [/@]
        [/#if]
    [/@]
[/@]

[@b.form name="roomListForm"]
  <input type="hidden" name="room.ids" value=""/>
  <input type="hidden" name="examType.id" value="${Parameters['examType.id']!}"/>
  <input type="hidden" name="semester.id" value="${Parameters['semester.id']!}"/>
  <input type="hidden" name="_params" value="${b.paramstring}" />
[/@]
[@b.foot/]
