

//  <script type="text/javascript">
    function getDischargePorts(ctx, vesVoy, line, selected) {
        loadDischargePortsForVVL(ctx, vesVoy.split("|")[0], vesVoy.split("|")[1], line, selected, true, "");
    }

    function loadDischargePortsForVVL(ctx, termVessel, termVoyage, line, selected, emptyOption, elementsToBeDisabled) {

        if(!(termVessel || termVoyage)) {
            if($("#loadPort").length) {
                $("#loadPort option").remove();
                $("#loadPort-total").empty();
                $("#loadPort").html("<option value=\"\" selected>Please select a Vessel/Voyage.</option>");
                $("#loadPort").attr('disabled', true);
            }

            if($("#dischargePort").length) {
                $("#dischargePort option").remove();
                $("#dischargePort-total").empty();
                $("#dischargePort").html("<option value=\"\" selected>Please select a Vessel/Voyage.</option>");
                $("#dischargePort").prop("disabled", true);
            }
        } else {

            if($("#dischargePort").val()) {
                clearPreviousValues("#dischargePort");
            }

            if($("#loadPort").val()) {
                clearPreviousValues("#loadPort");
            }

            if($("#dischargePort").length) {
                $("#dischargePort").html("<option value=\"\" selected>Loading...</option>");
            }

            if($("#loadPort").length) {
                $("#loadPort").html("<option value=\"\" selected>Loading...</option>");
            }

            if($(elementsToBeDisabled).length > 0) {
                $(elementsToBeDisabled).prop("disabled", true);
            }

            // make call
            $.getJSON(ctx + "/ajax/default.do?method=getDischargePorts&termVessel=" + termVessel + "&termVoyage=" + termVoyage + "&line=" + line)

                .done(function(json) {

                    if($("#dischargePort").length) {
                        $("#dischargePort-total").html(" (" + json.length + ")");
                    }

                    if($("#loadPort").length) {
                        $("#loadPort-total").html(" (" + json.length + ")");
                    }

                    if(json.length > 0) {
                        if($("#dischargePort").length) {
                            $("#dischargePort").attr('disabled', false);
                        }

                        if($("#loadPort").length) {
                            $("#loadPort").attr('disabled', false);
                        }

                        var items = [];
                        if(emptyOption) {
                            items.push("<option value=\"\"></option>");
                        }

                        $.each(json, function(key, val) {
                            items.push("<option value=\"" + val.termPortId + "\"" + selectedValue(val.termPortId, selected) + ">" + val.portName + " (" + val.linePortId + ")</option>");
                        });

                        items = items.join('');

                        if($("#dischargePort").length) {
                            $("#dischargePort").html(items);
                        }

                        if($("#loadPort").length) {
                            $("#loadPort").html(items);
                        }
                    } else {
                        if($("#dischargePort").length) {
                            $("#dischargePort").get(0).options[0] = new Option("No discharge ports found for selected Vessel/Voyage", "");
                            $("#dischargePort").prop("disabled", true);
                            $("#dischargePort-total").empty();
                        }
                        if($("#loadPort").length) {
                            $("#loadPort").get(0).options[0] = new Option("No load ports found for selected Vessel/Voyage", "");
                            $("#loadPort").prop("disabled", true);
                            $("#loadPort-total").empty();
                        }
                    }

                    if($(elementsToBeDisabled).length > 0) {
                        $(elementsToBeDisabled).prop("disabled", false);
                    }
                })

                .fail(function(jqxhr, textStatus, error) {
                    var err = textStatus + ", " + error;
                    //console.log("Request Failed: " + err);
            });
            $.cookie('saved_line', line, {path: '/'});
        }
    }

    function getLinesByAgency(agencyId) {
        $("#linesByAgency").empty();

        if(agencyId !== "") {
            $("#linesByAgency").html("Loading...");

            $.getJSON("../ajax/default.do?method=getLinesByAgency&agencyId=" + agencyId, function(data) {
                if ((data).length) {
                    var items = [];
                    $.each(data, function(key, val) {
                        items.push(val.companyId + " - " + val.companyName + "<br>");
                    });

                    if(items.length > 0) {
                        $("#linesByAgency").html("<strong>" + agencyId + "&nbsp;Associated&nbsp;Lines</strong> (" + items.length + ")<br>");
                        items = items.join('');
                        $("#linesByAgency").append(items);
                    } else {
                        $("#linesByAgency").html("No lines found.");
                    }
                }
            });
        }
    }

    function clearPreviousValues(elSelector){
        $(elSelector).attr('disabled', true);
        $(elSelector + " option").remove();
    }
    
    function deleteAppointment(aptSchedGkey, responseHandler) {
        //console.log("deleteAppointment clicked");
        if(aptSchedGkey === "") {
            console.log("aptSchedGkey is null");
        } else {
            $.get("/fc-PET/ajax/default.do?method=deleteAppointment", {aptSchedGkey: aptSchedGkey, timestamp: new Date().getTime()}, responseHandler);
        }
    }
    
    function deleteAppointmentTask(taskGkey, responseHandler, completed) {
        //console.log("deleteAppointmentTask clicked" + completed);
        if(taskGkey === "") {
            console.log("taskGkey is null");
        } else {
            $.get("/fc-PET/ajax/default.do?method=deleteAppointmentTask", {taskGkey: taskGkey, completed: completed, timestamp: new Date().getTime()}, responseHandler);
        }
    }
    
    function deductCharges(item, aptSchedGkey, responseHandler) {
        if(aptSchedGkey === "") {
            console.log("aptSchedGkey is null");
        } else {
            $.get("/fc-PET/fees/default.do?method=deductChargesFromAccount", item, {aptSchedGkey: aptSchedGkey, timestamp: new Date().getTime()}, responseHandler);
        }
    }

    function setLoadedValues(elSelector, optionsHtml, emptyOption){
        if(optionsHtml.length > 0) {
            $(elSelector).attr('disabled', false);
        }

        $(elSelector + " option").remove();
        if(emptyOption)
            $(elSelector).get(0).options[0] = new Option("", "");

        optionsHtml = optionsHtml.join('');
        $(elSelector).append(optionsHtml);
    }

    function getCompanies(ctx, companyType, selected, firstOptionName, firstOptionValue) {
        var dataString = "companyType=" + companyType;

        $.ajax({
            type: "POST",
            url: ctx + "/ajax/default.do?method=getCompanies",
            data: dataString,
            success: function(response, status) {
                $("#companyId option").remove();
                $("#companyId").get(0).options[0] = new Option("Loading...", "");

                var optionsHtml = new Array();

                $('company', response).each(function(){
                    var value = $(this).attr('id');
                    var label = $(this).attr('name');
                    optionsHtml.push("<option value=\"" + value + "\"" + selectedValue(value, selected) + ">" + label + "</option>");
                });

                if(optionsHtml.length > 0) {
                    $("#companyId").attr('disabled', false);
                }

                $("#companyId option").remove();
                if(firstOptionName && firstOptionValue)
                    $("#companyId").get(0).options[0] = new Option(firstOptionValue, firstOptionName);
                else
                    $("#companyId").get(0).options[0] = new Option("", "");

                optionsHtml = optionsHtml.join('');
                $("#companyId").append(optionsHtml);
            },
            error: function(xhr, textStatus, error) {
                $("#loading").html();
                $('#loading').html("A problem occurred: " + xhr.readyState + "-" + xhr.status + "-" + xhr.statusText + "-" + xhr.responseText + "-" + textStatus + "-" + error);
            }
        });
    }

    function getPools(ctx, line, selected) {
        if(line === "") {
            $("#pool option").remove();
            $("#pool").get(0).options[0] = new Option("Please select a Line.", "");
            $("#pool").prop("disabled", "disabled");
        } else {

            // initialize as disabled
            $("#pool").attr('disabled', true);

            // make call
            $.getJSON(ctx + "/ajax/default.do?method=getPools&line=" + line)

                .done(function(json) {
                    $("#totalPools").html(" (" + json.length + ")");
                    if(json.length > 0) {
                        var items = [];
                        $.each(json, function(key, val) {
                            items.push("<option value=\"" + val.poolId + "\"" + selectedValue(val.poolId, selected) + ">" + val.name + " (" + val.poolId + ")</option>");
                        });
                        items = items.join('');
                        $("#pool").html(items);
                        $("#pool").attr('disabled', false);
                    }
                })

                .fail(function(jqxhr, textStatus, error) {
                    var err = textStatus + ", " + error;
                    console.log("Request Failed: " + err);
            });
        }
    }

    function getSizeTypes(ctx, line, selected, alias, elementId, sztpClass) {
        if(line === "") {
            $("#" + elementId + " option").remove();
            $("#" + elementId).get(0).options[0] = new Option("Please select a Line.", "");
            $("#" + elementId).prop("disabled", "disabled");
            $("#" + elementId + "-total").empty();
        } else {

            $.getJSON(ctx + "/ajax/default.do?method=getSizeTypes&line=" + line + "&sztpClass=" + sztpClass, function(data) {

                $("#" + elementId + "-total").html(" (" + (data).length + ")");

                if((data).length===0){
                    $("#" + elementId).get(0).options[0] = new Option("No size/types found for selected Line", "");
                    $("#" + elementId).prop("disabled", "disabled");
                    $("#" + elementId + "-total").empty();
                } else {

                    $("#" + elementId).attr('disabled', false);

                    var items = '<option value=""></option>';
                    $.each(data, function(key, val) {
                        items += "<option value=\"" + val.termSztp + "\"" + selectedValue(val.termSztp, selected) + ">" + (alias === "TERM" ? val.termSztp : val.lineSztp) + "</option>";
                    });

                    $("#" + elementId).html(items);
                }
            })

            .fail(function(jqxhr, textStatus, error) {
                $("#error-message").fadeIn();
                //console.log("getSizeTypes Failed: " + textStatus + ", " + error);
            });

            $.cookie('saved_line', line, {path: '/'});
        }
    }

    function getVesselServices(ctx, line, selected) {
        if(line === "") {
            $("#service option").remove();
            $("#service").get(0).options[0] = new Option("Please select a Line.", "");
            $("#service").prop("disabled", "disabled");
            $("#service-total").empty();
        } else {

            // initialize as disabled
            $("#service").attr('disabled', true);

            // make call
            $.getJSON(ctx + "/ajax/default.do?method=getVesselServices&line=" + line)

                .done(function(json) {
                    $("#service-total").html(" (" + json.length + ")");
                    if(json.length > 0) {
                        var items = [];

                        // create empty element
                        items.push("<option value=\"\"></option>");

                        $.each(json, function(key, val) {
                            items.push("<option value=\"" + val.service + "\"" + selectedValue(val.service, selected) + ">" + val.servicesDesc + " (" + val.service + ")</option>");
                        });
                        items = items.join('');

                        $("#service").html(items);
                        $("#service").attr('disabled', false);
                    }
                })

                .fail(function(jqxhr, textStatus, error) {
                    var err = textStatus + ", " + error;
                    console.log("Request Failed: " + err);
            });
            $.cookie('saved_line', line, {path: '/'});
        }
    }

    function getTruckers(ctx, line, selected, elementId) {
        // if no value for line, don't attempt to get results
        if(line === "") {
            $("#" + elementId + " option").remove();
            $("#" + elementId).get(0).options[0] = new Option("Please select a Line.", "");
            $("#" + elementId).prop("disabled", "disabled");
            $("#" + elementId + "-total").empty();
        } else {

            // disable field while loading results
            $('#' + elementId).prop('disabled', true);

            // display a loading message
            document.getElementById(elementId).options[0].text = "Loading " + line + " truckers...";

            // make json call to get truckers
            $.getJSON(ctx + "/ajax/default.do?method=getTruckers&line=" + line + "&random=" + new Date().getTime(), function(data) {
                $("#" + elementId + "-total").html(" (" + (data).length + ")");

                // create empty element
                var items = '<option value=""></option>';

                // loop through result and build a list of options
                $.each(data, function(key, val) {
                    items += "<option value=\"" + val.terminalAlias + "\"" + selectedValue(val.terminalAlias, selected) + ">" + val.name + " (" + val.terminalAlias + ")</option>";
                });

                // set element with the list of options
                $("#" + elementId).html(items);

                // enable field
                $("#" + elementId).prop('disabled', false);
            });

            // set cookie to latest line selection
            $.cookie('saved_line', line, {path: '/'});
        }
    }

    /**
     * Ajax call to get Vessel/Voyages
     * @param ctx - page context
     * @param line - shipping line id
     * @param trgt - target element id to load to
     * @param direction - vessel direction (I) Inbound, (O) Outbound or ("") for both
     * @param selected - selected item in list
     * @param loadDiscPorts (boolean) - determines to make an additional call to load discharge ports lov
     * @param emptyOption (boolean) - include an empty option item
     * @param includeSailed (boolean) - determine if list should include voyages that have already sailed
     */

    function getVesselVoyages(ctx, line, trgt, direction, selected, loadDiscPorts, emptyOption, includeSailed) {
    	getVesselVoyagesLloyds(ctx, line, trgt, direction, selected, loadDiscPorts, emptyOption, includeSailed, false);
    }

    function getVesselVoyagesLloyds(ctx, line, trgt, direction, selected, loadDiscPorts, emptyOption, includeSailed, includeLloydsId) {

        if(line === "") {
            $("#" + trgt + " option").remove();
            $("#" + trgt).get(0).options[0] = new Option("Please select a Line.", "");
            $("#" + trgt).prop("disabled", "disabled");
            $("#" + trgt + "-total").empty();
        } else {

            var dataString = "line=" + line + "&direction=" + direction + "&includeSailed=" + includeSailed + "&includeLloydsId=" + includeLloydsId;

            $.ajax({
                type: "POST",
                url: ctx + "/ajax/default.do?method=getVesselVoyages",
                data: dataString,
                success: function(response, status) {
                    $("#" + trgt + " option").remove();
                    $("#" + trgt).html("<option value=\"\" selected>Loading...</option>");

                    var optionsHtml = new Array();

                    $('item', response).each(function(){
                        var value = $(this).attr('value');
                        var name = $(this).attr('name');
                        //console.log(value);
                        optionsHtml.push("<option value=\"" + value + "\"" + selectedValue(value, selected) + ">" + name + "</option>");
                    });

                    if(optionsHtml.length > 0) {
                        $("#" + trgt).attr('disabled', false);
                    }

                    $("#" + trgt + "-total").html(" (" + optionsHtml.length + ")");
                    $("#" + trgt + " option").remove();
                    $("#" + trgt).html("<option value=\"\" selected></option>");

                    optionsHtml = optionsHtml.join('');
                    $("#" + trgt).append(optionsHtml);
                    $("#" + trgt).change();

                    if(status === "success" && loadDiscPorts) {
                        getDischargePorts(ctx,$("#" + trgt).val(),line,'');
                    }

                },
                error: function(xhr, textStatus, error) {
                    $("#loading").html();
                    $('#loading').html("A problem occurred: " + xhr.readyState + "-" + xhr.status + "-" + xhr.statusText + "-" + xhr.responseText + "-" + textStatus + "-" + error);
                }
            });

            $.cookie('saved_line', line, {path: '/'});
        }
    }

    function getVesselVoyagesTermOnly(ctx, line, trgt, direction, selected, loadDiscPorts, emptyOption) {

        $("#" + trgt + " option").remove();
        $("#" + trgt).html("<option value=\"\" selected>Loading...</option>");

        var dataString = "line=" + line + "&direction=" + direction;

        $.ajax({
            type: "POST",
            url: ctx + "/ajax/default.do?method=getVesselVoyagesTermOnly",
            data: dataString,
            success: function(response, status) {

                var optionsHtml = new Array();

                $('item', response).each(function(){
                    var value = $(this).attr('value');
                    var name = $(this).attr('name');
                    optionsHtml.push("<option value=\"" + value + "\"" + selectedValue(value, selected) + ">" + name + "</option>");
                });

                if(optionsHtml.length > 0) {
                    $("#" + trgt).prop('disabled', false);
                }

                $("#" + trgt + "-total").html(" (" + optionsHtml.length + ")");
                $("#" + trgt + " option").remove();
                $("#" + trgt).html("<option value=\"\" selected></option>");

                optionsHtml = optionsHtml.join('');
                $("#" + trgt).append(optionsHtml);
                $("#" + trgt).change();

                if(status === "success" && loadDiscPorts) {
                    getDischargePorts(ctx,$("#" + trgt).val(),line,'');
                }

            },
            error: function(xhr, textStatus, error) {
                $("#loading").html();
                $('#loading').html("A problem occurred: " + xhr.readyState + "-" + xhr.status + "-" + xhr.statusText + "-" + xhr.responseText + "-" + textStatus + "-" + error);
            }
        });

        $("#" + trgt).prop('disabled', false);
    }

    function selectedValue(val1, val2) {
        if (val1 === val2) {
            return " selected";
        } else {
            return "";
        }
    }

    function getInOutVesselVoyages(ctx, line, isActive, numberOfDays, selected, emptyOption, elementSelector, elementsToBeDisabled) {
        $(elementSelector + " option").remove();

        if(line === ""){
            return;
        }
        $(elementSelector).html("<option value=\"\" selected>Loading...</option>");

        if($(elementsToBeDisabled).length > 0) {
            $(elementsToBeDisabled).prop("disabled", true);
        }

        var dataString = "line=" + line + "&isActive=" + isActive + "&numberOfDays=" + numberOfDays;

        $.ajax({
            type: "POST",
            url: ctx + "/ajax/default.do?method=getInOutVesselVoyages",
            data: dataString,
            success: function(response, status) {

                var values = new Array();
                var names = new Array();
                $('item', response).each(function(i){
                    values[i] = $(this).attr('value');
                    names[i] = $(this).attr('name');
                });

                if(emptyOption) {
                    $(elementSelector).get(0).options[0] = new Option("", "");
                }

                var optionsHtml = "";

                for (var i = 0; i < names.length; i++ ) {
                    optionsHtml+="<option value=\"" + values[i] + "\"" + selectedValue(values[i], selected) + ">" + names[i] + "</option>";
                }

                $(elementSelector).append(optionsHtml);

                if($(elementsToBeDisabled).length > 0) {
                    $(elementsToBeDisabled).prop("disabled", false);
                }
            },
            error: function(xhr, textStatus, error) {
                alert("A problem occurred: " + xhr.readyState + "-" + xhr.status + "-" + xhr.statusText + "-" + xhr.responseText + "-" + textStatus + "-" + error);
            }
        });

    }

    function getDestinationPorts(ctx, line, selected) {
        if(line === "") {
            $("#destination option").remove();
            $("#destination-total").empty();
            $("#destination").get(0).options[0] = new Option("Please select a Line.", "");
            $("#destination").prop("disabled", true);
        } else {

            // initialize as disabled and loading
            $("#destination").attr('disabled', true);
            $("#destination").html("<option value=\"\" selected>Loading...</option>");

            // make call
            $.getJSON(ctx + "/ajax/default.do?method=getDestinationPorts&line=" + line)

                .done(function(json) {
                    $("#destination-total").html(" (" + json.length + ")");
                    if(json.length > 0) {
                        var items = [];
                        items.push("<option value=\"\"></option>");
                        $.each(json, function(key, val) {
                            items.push("<option value=\"" + val.termPortId + "\"" + selectedValue(val.termPortId, selected) + ">" + val.portName + "</option>");
                        });
                        items = items.join('');
                        //console.log("destinationPorts: " + items);
                        $("#destination").html(items);
                        $("#destination").attr('disabled', false);
                    } else {
                        if($("#destination").length) {
                            $("#destination").get(0).options[0] = new Option("No destinations found for selected Line", "");
                            $("#destination").prop("disabled", true);
                            $("#destination-total").empty();
                        }
                    }
                })

                .fail(function(jqxhr, textStatus, error) {
                    var err = textStatus + ", " + error;
                    console.log("Request Failed: " + err);
            });
        }
    }

    function autocompleteBillParty(ctx, billingPartyCode, elementId) {

        $(elementId).empty();

        if(billingPartyCode !== "") {
            $("#verify").attr('disabled', true);
            $(elementId).removeClass("billingPartyName");
            $(elementId).addClass("hint");
            $(elementId).html("searching...");

            $.getJSON(ctx + "/ajax/default.do?method=getBillingParties&billingPartyCode=" + billingPartyCode)
                .done(function(json) {
                    if(json.length === 1) {
                        $(elementId).removeClass("hint");
                        $(elementId).addClass("billingPartyName");
                        $(elementId).html(json[0].name);
                        $("#billingPartyFound").val("true");
                    } else {
                        $(elementId).html("Billing Party could not be found.");
                        $("#billingPartyFound").val("false");
                    }
                })

                .fail(function(jqxhr, textStatus, error) {
                    var err = textStatus + ", " + error;
                    console.log("Request Failed: " + err);
            });

            $("#verify").attr('disabled', false);
        }
    }

    function getMainsailParameter(ctx, paramName, line) {
        var result = "";
        if(paramName !== "" && line !== "") {
            $.ajax({
                type: "POST",
                async: false,
                url: ctx + "/ajax/default.do?method=getMainsailParameterSetting",
                data: {'param': paramName, 'line': line},
                success: function(data){
                    result = data;
                },
                error: function(xhr, textStatus, error) {
                    alert("A problem occurred: " + xhr.readyState + "-" + xhr.status + "-" + xhr.statusText + "-" + xhr.responseText + "-" + textStatus + "-" + error);
                }
            });
        }
        return result;
    }
    
    function getCompanies(ctx, companyType, selected, sortBy) {
        
        if (companyType) {
            $("#companyType").prop('disabled', true);
            $("#companyId").prop("disabled", true);

            $.ajax({
                type: "POST",
                url: ctx + "/ajax/default.do", 
                data: {"method": "getCompanies", "companyType": companyType, "sortBy": sortBy, "selected": selected}, 
                success: function(data) {
                    var items = [];
                    //console.log(data);
                    items.push("<option value=\"\"></option>");
                    $.each(data, function(key, val) {
                        items.push("<option value=\"" + val.companyId + "\"" + selectedValue(val.companyId, selected) + ">" + val.companyName + " (" + val.companyId + ")</option>");
                    });
                    items = items.join('');
                    $("#companyId").html(items);
                    $("#companyId").attr('disabled', false);
                },
                error: function(xhr, textStatus, error) {
                    alert("A problem occurred: " + xhr.readyState + "-" + xhr.status + "-" + xhr.statusText + "-" + xhr.responseText + "-" + textStatus + "-" + error);
                }
            });
            
            $("#companyType").prop('disabled', false);
            $("#companyId").attr('disabled', false);
        }
    }
    
    /**
     * Retrieve billing parties.
     * 
     * @param {string} (optional) selected value.
     */
    function getBillingParties(selected) {
        
        $("#companyType").prop('disabled', true);
        $("#companyId").prop("disabled", true);
        
        var preselected = (selected === undefined ? "" : selected);

        $.ajax({
            type: "POST",
            url: "../ajax/default.do", 
            data: {"method": "getBillingParties"}, 
            success: function(data) {
                var items = [];
                //console.log(data);
                items.push("<option value=\"\"></option>");
                $.each(data, function(key, val) {
                    items.push("<option value=\"" + val.code + "\"" + selectedValue(val.code, preselected) + ">" + val.name + " (" + val.code + ")</option>");
                });
                items = items.join('');
                $("#companyId").html(items);
                $("#companyId").attr('disabled', false);
            },
            error: function(xhr, textStatus, error) {
                alert("A problem occurred: " + xhr.readyState + "-" + xhr.status + "-" + xhr.statusText + "-" + xhr.responseText + "-" + textStatus + "-" + error);
            }
        });

        $("#companyType").prop('disabled', false);
    }
//  </script>