## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
from django.utils.html import escape

from desktop.lib.i18n import smart_unicode
from desktop.views import commonheader, commonfooter
from django.utils.translation import ugettext as _
%>

<%namespace name="components" file="components.mako" />

<%
  if table.is_view:
    view_or_table_noun = _("View")
  else:
    view_or_table_noun = _("Table")
%>

${ commonheader(_("%s : %s") % (view_or_table_noun, table.name), app_name, user) | n,unicode }
${ components.menubar() }

<link rel="stylesheet" href="${ static('metastore/css/metastore.css') }" type="text/css">


<%def name="column_table(cols, withStats=False)">
  <table class="table table-striped table-condensed sampleTable
  %if withStats:
  skip-extender
  %endif
  ">
    <thead>
      <tr>
        %if withStats:
          <th width="10">&nbsp;</th>
        %endif
        <th width="10">&nbsp;</th>
        <th>${_('Name')}</th>
        <th>${_('Type')}</th>
        <th>${_('Comment')}</th>
      </tr>
    </thead>
    <tbody>
      % for column in cols:
        <tr>
          %if withStats:
            <td class="row-selector-exclude"><a href="javascript:void(0)" data-column="${ column.name }"><i class="fa fa-bar-chart" title="${ _('View statistics') }"></i></a></td>
          %endif
          <td>${ loop.index }</td>
          <td title="${ _("Scroll to the column") }">
            <a href="javascript:void(0)" data-row-selector="true" class="column-selector">${ column.name }</a>
          </td>
          <td>${ column.type }</td>
          <td>${ column.comment != 'None' and smart_unicode(column.comment) or "" }</td>
        </tr>
      % endfor
    </tbody>
  </table>
</%def>

<div class="container-fluid">
  <div class="row-fluid">
    <div class="span3">
      <div class="sidebar-nav card-small">
        <ul class="nav nav-list">
          <li class="nav-header">${_('Actions')}</li>
          % if has_write_access:
          <li><a href="#" id="import-data-btn"><i class="fa fa-arrow-circle-o-down"></i> ${_('Import Data')}</a></li>
          % endif
          <li><a href="${ url('metastore:read_table', database=database, table=table.name) }"><i class="fa fa-list"></i> ${_('Browse Data')}</a></li>
          % if has_write_access:
          <li><a href="#dropTable" data-toggle="modal"><i class="fa fa-trash-o"></i> ${_('Drop')} ${view_or_table_noun}</a></li>
          % endif
          <li><a href="${ table.hdfs_link }" rel="${ table.path_location }"><i class="fa fa-share-square-o"></i> ${_('View File Location')}</a></li>
          % if table.partition_keys:
          <li><a href="${ url('metastore:describe_partitions', database=database, table=table.name) }"><i class="fa fa-sitemap"></i> ${_('Show Partitions')} (${ len(partitions) })</a></li>
          % endif
        </ul>
      </div>
    </div>
    <div class="span9">
      <div class="card card-small">
        <h1 class="card-heading simple">${ components.breadcrumbs(breadcrumbs) }</h1>
        <div class="card-body">
          <p>
            % if table.comment:
            <div class="alert alert-info">${ _('Comment:') } ${ smart_unicode(table.comment) }</div>
            % endif

            <ul class="nav nav-tabs">
              <li><a href="#columns" data-toggle="tab">${_('Columns')}</a></li>
              % if table.partition_keys:
              <li><a href="#partitionColumns" data-toggle="tab">${_('Partition Columns')}</a></li>
              % endif
              % if sample is not None:
              <li><a href="#sample" data-toggle="tab">${_('Sample')}</a></li>
              % endif
              <li><a href="#properties" data-toggle="tab">${ _('Properties') }</a></li>
            </ul>

            <div class="tab-content">
              <div class="tab-pane" id="columns">
                ${ column_table(table.cols, True) }
              </div>

              % if table.partition_keys:
              <div class="tab-pane" id="partitionColumns">
                ${ column_table(table.partition_keys) }
              </div>
              % endif

              % if sample is not None:
              <div class="tab-pane" id="sample">
              % if error_message:
                <div class="alert alert-error">
                  <h3>${_('Error!')}</h3>
                  <pre>${error_message | h}</pre>
                </div>
              % else:
                <table id="sampleTable" class="table table-striped table-condensed sampleTable">
                  <thead>
                    <tr>
                      <th style="width: 10px"></th>
                    % for col in table.cols:
                      <th>${col.name}</th>
                    % endfor
                    </tr>
                  </thead>
                  <tbody>
                  % for i, row in enumerate(sample):
                    <tr>
                      <td>${ i }</td>
                    % for item in row:
                      <td>
                        % if item is None:
                          NULL
                        % else:
                          ${ escape(smart_unicode(item, errors='ignore')).replace(' ', '&nbsp;') | n,unicode }
                        % endif
                      </td>
                    % endfor
                    </tr>
                  % endfor
                  </tbody>
                </table>
              % endif
              </div>
              % endif

              <div class="tab-pane" id="properties">
                <table class="table table-striped table-condensed">
                  <thead>
                    <tr>
                      <th>${ _('Name') }</th>
                      <th>${ _('Value') }</th>
                      <th>${ _('Comment') }</th>
                    </tr>
                  </thead>
                  <tbody>
                    % for prop in table.properties:
                      <tr>
                        <td>${ smart_unicode(prop['col_name']) }</td>
                        <td>${ smart_unicode(prop['data_type']) if prop['data_type'] else '' }</td>
                        <td>${ smart_unicode(prop['comment']) if prop['comment'] else '' }&nbsp;</td>
                      </tr>
                     % endfor
                  </tbody>
                </table>
              </div>
            </div>
          </p>
        </div>
      </div>
    </div>
  </div>
</div>

<div id="dropTable" class="modal hide fade">
  <form id="dropTableForm" method="POST" action="${ url('metastore:drop_table', database=database) }">
    ${ csrf_token(request) | n,unicode }
    <div class="modal-header">
      <a href="#" class="close" data-dismiss="modal">&times;</a>

      <h3>${_('Drop Table')}</h3>
    </div>
    <div class="modal-body">
      <div id="dropTableMessage">
      </div>
    </div>
    <div class="modal-footer">
      <input type="button" class="btn" data-dismiss="modal" value="${_('Cancel')}"/>
      <input type="submit" class="btn btn-danger" value="${_('Yes, drop this table')}"/>
    </div>
    <div class="hide">
      <select name="table_selection">
        <option value="${ table.name }" selected>${ table.name }</option>
      </select>
    </div>
  </form>
</div>

<div id="import-data-modal" class="modal hide fade"></div>
</div>

<div id="columnAnalysis" class="popover mega-popover right">
  <div class="arrow"></div>
  <h3 class="popover-title" style="text-align: left">
    <a class="pull-right pointer close-popover" style="margin-left: 8px"><i class="fa fa-times"></i></a>
    <strong class="column-name"></strong> ${ _(' column analysis') }
  </h3>
  <div class="popover-content" style="text-align: left"></div>
</div>


<script type="text/javascript" charset="utf-8">
  $(document).ready(function () {

    $(".column-selector").on("click", function () {
      var _t = $("#sample");
      var _text = $.trim($(this).text().split("(")[0]);
      var _col = _t.find("th").filter(function() {
        return $.trim($(this).text()) == _text;
      });
      _t.find(".columnSelected").removeClass("columnSelected");
      _t.find("tr td:nth-child(" + (_col.index() + 1) + ")").addClass("columnSelected");
      $("a[href='#sample']").click();
    });

    % if has_write_access:
        $.getJSON("${ url('metastore:drop_table', database=database) }", function (data) {
          $("#dropTableMessage").text(data.title);
        });
    % endif

    $('a[data-toggle="tab"]').on('shown', function () {
      $(".sampleTable").not('.initialized').addClass('initialized').dataTable({
        "bPaginate": false,
        "bLengthChange": false,
        "bInfo": false,
        "bFilter": false,
        "fnInitComplete": function () {
          $(this).parent().jHueTableScroller();
          if ($(this).hasClass("skip-extender")){
            $(this).jHueTableExtender({
              includeNavigator: false,
              fixedHeader: true
            });
          }
          else {
            $(this).jHueTableExtender({
              hintElement: "#jumpToColumnAlert",
              fixedHeader: true
            });
          }
        },
        "oLanguage": {
          "sEmptyTable": "${_('No data available')}",
          "sZeroRecords": "${_('No matching records')}"
        }
      });
    });

    $("#import-data-btn").click(function () {
      $.get("${ url('metastore:load_table', database=database, table=table.name) }", function (response) {
          $("#import-data-modal").html(response['data']);
          $("#import-data-modal").modal("show");
        }
      );
    });

    // convert link text to URLs in comment column (Columns tab)
    hue.text2Url(document.querySelectorAll('.sampleTable td:last-child'));

    $('a[data-toggle="tab"]:eq(0)').click();

    $("a[data-column]").on("click", function(){
      var _link = $(this);
      var _col = _link.data("column");
      var statsUrl = "/impala/api/table/${database}/${table.name}/stats/" + _col;
      $("#columnAnalysis .popover-content").html("<i class='fa fa-spinner fa-spin'></i>");
      $("#columnAnalysis").show().css("top", _link.position().top - $("#columnAnalysis").outerHeight()/2 + _link.outerHeight()/2).css("left", _link.position().left + _link.outerWidth());
      $.ajax({
        url: statsUrl,
        data: {},
        beforeSend: function (xhr) {
          xhr.setRequestHeader("X-Requested-With", "Hue");
        },
        dataType: "json",
        success: function (data) {
          if (data && data.status == 0){
            var _stats = "<table class='table table-striped'>";
            data.stats.forEach(function(item){
              _stats += "<tr><th>" + Object.keys(item)[0] + "</th><td>" + item[Object.keys(item)[0]] + "</td></tr>";
            });
            _stats += "</table>"
            $("#columnAnalysis .column-name").text(_col);
            $("#columnAnalysis .popover-content").html(_stats);
            $("#columnAnalysis .popover-content").css("opacity", "1");
            $("#columnAnalysis").show().css("top", _link.position().top - $("#columnAnalysis").outerHeight()/2 + _link.outerHeight()/2).css("left", _link.position().left + _link.outerWidth());
          }
          else {
            $(document).trigger("error", "${ _('There was a problem loading the table stats.') }");
            $("#columnAnalysis").hide();
          }
        },
        error: function (e) {
          if (e.status == 500) {
            $(document).trigger("error", "${ _('There was a problem loading the table stats.') }");
            $("#columnAnalysis").hide();
          }
        }
      });
    });

    $(document).on("click", ".close-popover", function () {
      $("#columnAnalysis").hide();
    });

  });
</script>

${ commonfooter(messages) | n,unicode }
