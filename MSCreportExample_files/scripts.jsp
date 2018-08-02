



//<script type="text/javascript">
    function clearAlert(){
        $("#headerAlert,#alert,#footerAlert").hide();
        $("#headerAlert,#alert,#footerAlert", window.parent.document).hide();
    }

    function setNavStyle(id) {
        $(id).addClass("active");
    }

    /**
     * Compares 2 dates to determine whether the first is greater than, less than
     * or equal to the second.
     * 
     * @param {Date} date1 First date
     * @param {Date} date2 Second date.
     * @returns {Number} A negative number when date1 < date2, a positive number 
     *   when date1 > date2 or 0 when the two dates are the same.  Will 
     *   return 100 if either of the date parameters is null.
     */
    function dateCompare(date1, date2) {
        
        if (date1 !== null && date2 !== null) {
            return Date.parse(date1) - Date.parse(date2);
        }
        
        return 100;
    }

    //--------------------------------------------------------------------------------
    /**
     * Detemines whether a year is a leap year.
     * @param year -
     */
    function isLeapYear(year) {
        return (((year % 4 === 0) && (year % 100 !== 0)) || (year % 400 === 0));
    }

    //--------------------------------------------------------------------------------
    /**
     * Returns a boolean indicating if the value passed to the function conforms to
     * a proper date format.  Note that this function determines only that the month
     * and day fall within correct value ranges.  No assessment is made on the year value
     * other than verifying that the year has been specified with four digits.
     * @param value -
     * @param locale -
     */
    function isDate(value, locale) {
        var daysInMonth;
        var dateParts;
        var maxDayInMonth;
        var month;
        var day;
        var year;
        if(hasData(value)) {

            dateParts = trim(value).match(/^([1-9]|0[1-9]|1[012]|[12][0-9]|3[01])[\/\-.]([1-9]|0[1-9]|1[012]|[12][0-9]|3[01])[\/\-.](\d{4})$/);

            /* Code note: if a radix (base 10) is not specified for the parseInt function below, it will return
           incorrect results for non octagonal numbers like 08 and 09 */
            if(dateParts !== null && dateParts.length === 4) {
                if (locale === "en_US"){
                    month = parseInt(dateParts[1], 10);
                    day = parseInt(dateParts[2], 10);
                    year = parseInt(dateParts[3], 10);
                } else {
                    month = parseInt(dateParts[2], 10);
                    day = parseInt(dateParts[1], 10);
                    year = parseInt(dateParts[3], 10);
                }

                daysInMonth = new Array(31, (isLeapYear(year) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

                maxDayInMonth = daysInMonth[month - 1];

                return (!(month < 1 || month > 12) && !(day < 1 || day > maxDayInMonth));
            }

            return false;
            //no date value specified or invalid date format
        }
    }

    /**
     * Determines if parameter represents an email address
     * @param value - form field value (example: $("#id").val())
     */
    function isEmail(value){
        var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        return regex.test(value);
    }

   /**
    * Detects and warns if a text value contains disallowed characters.  Additonally,
    * If wildcard characters are allowed, a warning will be issued if the text value
    * contains only wildcard characters.
    * @param text -
    * @param useWildcards -
    */
    function invalidChars(text, useWildcards) {
        var re = ((useWildcards !== undefined) && useWildcards ? /[!':?<>|@#$^&\";.\\]/ : /[!':*?<>|@#$%^&\";.\\]/);
        if (re.test(text)) {
            alert("Please do not enter the following characters:\n\n" + re.source.slice(1, re.source.length-1));
            return false;
        }

        if (useWildcards && trim(text.length) > 0 && trim(text.replace(/[%*]/g, '')) === '') {
            alert('Please enter a valid search term along with wildcard.');
            return false;
        }

        return true;
    }

    function showSearchTypeAvail(item) {
        if (item === "BOL") {
            $("#scacArea").show();
            $("#bolHint").show();
            $("#bookingHint").hide();
            $("#containerHint").hide();
            $("#numbers").css("height", "8em");
        } else if (item === "BKG") {
            $("#scacArea").hide();
            $("#bolHint").hide();
            $("#bookingHint").show();
            $("#containerHint").hide();
            $("#numbers").css("height", "2.5em");
        } else {
            $("#scacArea").hide();
            $("#bolHint").hide();
            $("#bookingHint").hide();
            $("#containerHint").show();
            $("#numbers").css("height", "8em");
        }
    }

    function validateImportData(){
        if (!validationItem("numbers")) {
            twitterAlertMessage("Please enter a number.");
            return false;
        }
        if (!invalidChars($('#numbers').val())) {
            return false;
        }
        
        if($("#searchBy").val() === "BKG") {
            if(!validateCount("numbers", 1)) {
                twitterAlertMessage("Please limit your search to 1 containers");
                return false;
            }
        } else {
            if(!validateCount("numbers", 50)) {
                twitterAlertMessage("Please limit your search to 50 containers");
                return false;
            }        
        }
        return true;
    }

    function checkForAllRemoved(maxAmount, type) {

        var sGrandTotal = parseFloat(document.getElementById("grandTotal").innerHTML.replace(/[^0-9\.]+/g,""));
        var sMaxAmount = parseFloat(maxAmount);
        
        if (sGrandTotal > sMaxAmount) {
            alert("You have a $" + maxAmount + " "
                + "limit on daily fees you can" + " " + type + " "
                + "for. Please adjust your amounts.\n\nIf you have any questions please contact the Terminal.");
            return false;
        }

        var numRemoved = 0;
        var numAvail = 0;
        var checkBoxes = document.getElementsByName("FeeExclusions");
        var maxCheckboxes = checkBoxes.length;

        if (maxCheckboxes === undefined) {
            if (document.imports.FeeExclusions.checked === false) {
                numRemoved = 1;
                numAvail = 1;
            } else {
                numRemoved = 0;
                numAvail = 1;
            }
        } else {
            for ( var idx = 0; idx < maxCheckboxes; idx++) {
                if (checkBoxes[idx].disabled === false) {
                    numAvail += 1;
                    if (checkBoxes[idx].checked === false) {
                        numRemoved += 1;
                        $('<input>').attr({
                            type: 'hidden',
                            name: checkBoxes[idx].value,
                            value: 'false'}).appendTo($('#confirmProcessForm'));
                    } else{
                        $('<input>').attr({
                            type: 'hidden',
                            name: checkBoxes[idx].value,
                            value: 'true'}).appendTo($('#confirmProcessForm'));
                    }
                }
            }
        }

        if (numRemoved === numAvail) {
            alert("You have chosen to remove all fees from all containers.\n\nPlease select a charge to pay for before continuing.");
            return false;
        } else {
            $("#confirmTransactionData").val(type);
            $("#confirmProcessForm").submit();
        }
    }

    function checkPaging(elem, iPage, iPageCount) {
        if (elem === "") {
            return false;
        } else {
            if (elem === iPage) {
                return false;
            } else {
                if ((isNaN(elem)) || !(parseInt(elem) > 0 && parseInt(elem) <= parseInt(iPageCount)) ) {
                    alert("Please enter a page number between 1 and" + " " + iPageCount + '.');
                    return false;
                }
            }
        }
        return true;
    }

    //--------------------------------------------------------------------------------
    function limitLength(fieldref, maxlength, message) {
        if ($(fieldref).val().length > maxlength) {
            $(fieldref).val($(fieldref).val().substring(0, maxlength));
            alert((message ? message : 'This field accepts a maximum of ' + maxlength + ' characters'));
        }
    }

    /**
     * JQuery event-handling function used to limit the length of input on
     * TextArea fields.  The data object is expected to contain two properties:
     * <ul>
     *   <li>"maxlength" for the maximum number of characters allowed and</li>
     *   <li>"message" for the message to dispay when the limit has been exceeded.</li>
     * </ul>
     * @param event -
    */
    function limitFieldLength(event) {
        var field = event.target;
        var max = event.data.maxlength;
        if (field.value.length > max) {
            field.value = field.value.substring(0, max);
            alert(event.data.message);
        }
    }

    function smsAddressSet(item,address) {
        if(item.checked && address === "") {
            alert("Your profile must include a mobile number in order to receive SMS notifications.\nPlease proceed to your account settings and update.");
            return false;
        } else {
            return true;
        }
    }

    function isValidContainerNumber(containerNum) {
        if(hasData(containerNum)) {
            containerNum = trim(containerNum);
            //non alphanumeric characters
            var reg1 = "[^A-Z0-9]";
            //4 alpha and 6 or 7 numeric
            var pattern = "^[a-zA-Z]{4}[0-9]{6,7}";
            containerNum = containerNum.toUpperCase();

            if((containerNum.match(reg1)) || (!containerNum.match(pattern))) {
                return false;
            }
        }
        return true;
    }

    function isAlphaNumeric(field, wildcard) {
        if(hasData(field)) {
            var regex = /[^a-zA-Z0-9]/;
            if(wildcard) {
                regex = /[^a-zA-Z0-9%]/;
            }
            if(regex.test(trim(field))) {
                return false;
            }
        }
        return true;
    }

    function formatUSDate(dateStr,format) {
        if(dateStr === null) {
            return null;
        }
        try {
            var parts = dateStr.split("/");
            var month = parts[0];
            var day = parts[1];
            var year= parts[2];

            if(format === 'dd/MM/yyyy') {
                return day + "/" + month + "/" + year;
            } else if(format === 'yyyy/MM/dd') {
                return month + "/" + day + "/" + year;
            } else {
                return dateStr;
            }
        }

        catch(e) {
            // bad input string, probably
        }
        return null;
    }

    function localizeDate(dateStr,dateFormatPref) {
        if(dateStr === null) {
            return null;
        }
        try {
            var parts = dateStr.split("/");
            var zero = parts[0];
            var one = parts[1];
            var two= parts[2];

            if(dateFormatPref === 'yyyy/MM/dd') {
                return one + "/" + two + "/" + zero;
            } else if (dateFormatPref === 'dd/MM/yyyy') {
                return one + "/" + zero + "/" + two;
            } else {
                return zero + "/" + one + "/" + two;
            }
        }

        catch(e) {
            // bad input string, probably
        }
        return null;
    }

    REDIRECTED_HEADER = "REDIRECTED_FROM";

    /**
    * Loads a page to the target element. If there is session timeout,
    * prevents login page to be loaded to the target element, instead makes
    * redirecting to it.
    * @param url page to be load
    * @param targetSelector jquery selector of target element.
    *
    * IE browsers not support this functionality.
    * @see loadPageFragment(url, targetSelector)
    */
    function loadPageFragment(url, targetSelector) {
        if(url.indexOf("?") > 0){
            url = url + "&timestamp=" + new Date().getTime();
        } else {
            url = url + "?timestamp=" + new Date().getTime();
        }

        $.get(url, function(data, textStatus, jqXHR) {
            if (!!jqXHR.getResponseHeader(REDIRECTED_HEADER)) {
                window.location.replace(jqXHR.getResponseHeader(REDIRECTED_HEADER));
                return;
            }
            $(targetSelector).html(data);
            Shadowbox.setup();
        });
    }

    //if a new image is added to the master equipment image, it will need to be added here.
    function findEquipmentImage(sizetype, status, eqClass){

        var found = false;

        if(eqClass==="CTR" && (status === "E" && (sizetype === "20DR" || sizetype === "20RF" || sizetype === "40DR" || sizetype === "40RF"))) {
            $("#equipmentImage").attr("src", "../images/equipment/" + sizetype + "_EMPTY.png");
            found = true;
        }

        if(!found){

            var equipment = new Array("20BK", "20CF", "20CH", "20DF", "20DH", "20DR", "20FR", "20GN", "20HV", "20OT", "20PF", "20PP", "20RF", "20RH", "20RT", "20TK", "24CH", "24DH", "24DR", "24GN", "24TK", "40AR", "40CH", "40DH", "40DR", "40FB", "40FR", "40GN", "40OT", "40PF", "40RF", "40RH", "40RT", "40SF", "40TK", "45DH", "45EX", "45FB", "45RH", "48DH", "48RR", "48VN", "53DR");

            for(i = 0; i < equipment.length; i++) {
                if(equipment[i] === sizetype) {
                    found = true;
                    $("#equipmentImage").attr("src", "../images/equipment/" + sizetype + ".png");
                    break;
                } else {
                    found = false;
                }
            }

            if(!found) {
                if(eqClass==="CHASSIS") {
                    $("#equipmentImage").attr("src", "../images/equipment/CHASSIS.png");
                } else {
                    $("#equipmentImage").attr("src", "../images/equipment/CONTAINER.png");
                }
            }
        }
    }

    function twitterAlertMessage(msg, callback, fadeoutTime){
        if(msg.length > 150){
            alert(msg);
        } else {
            var alertDiv = $("#headerAlert").size() === 1 ? $("#headerAlert") : $("#headerAlert", window.parent.document);
            var timeDelay = fadeoutTime ? fadeoutTime : 2000;

            $(alertDiv).twitter_alert({
                message: msg,
                fadeout_time: timeDelay,
                bg_colour: '#ff5a00',
                text_size: '16px',
                font_weight: 'bold',
                text_colour: '#FFF',
                border_colour: '#7a015c'
            });
        }
        if(callback) setTimeout(callback, timeDelay);
    }

    function removeNotifications(dataString, url, id){
        var confirmed = confirm("Are you sure?");
        if (!confirmed) {
            return false;
        }

        $.ajax({
            type: "POST",
            url: url,
            data: dataString,
            success: function(response, status) {
                if ($('result', response).attr("message") !== "") {
                    var result = $('result', response).attr("message");
                } else {
                    var result = 'Successfully deleted!';
                    setTimeout(function(){
                        $('#'+id, window.parent.document).click();
                    },500);
                }

                twitterAlertMessage(result);
            },
            error: function(xhr, textStatus, error) {
                alert("A problem occurred: " + xhr.readyState + "-" + xhr.status + "-" + xhr.statusText + "-" + xhr.responseText + "-" + textStatus + "-" + error);
            }
        });
    }

    function validationCheckbox(item){
        var valid = true;
        $("#" + item + "-label").removeClass("missing");
        $("#" + item).removeClass("missingField");

        if(!$("input[name=" + item + "]:checked").attr('checked')) {
            valid = false;
            $("#" + item + "-label").addClass("missing");
            $("#" + item).addClass("missingField");
        }
        return valid;
    }

    function validationCheckboxByClass(className, item){
        var valid = true;
        $("#" + item + "-label").removeClass("missing");
        $("#" + item).removeClass("missingField");

        if(!$("." + className).is(':checked')) {
            valid = false;
            $("#" + item + "-label").addClass("missing");
            $("#" + item).addClass("missingField");
        }
        return valid;
    }

    function validationFormItems(items){
        var valid = true;
        $.each(items, function(key, id) {
            if(!validationItem(id)){
                valid = false;
            }
        });
        return valid;
    }

    function validationItem(itemId){
        //console.log("itemId:" + itemId);
        var valid = true;
        $("#" + itemId + "-label").removeClass("missing");
        $("#" + itemId).removeClass("missingField");

        valid = hasData($("#" + itemId).val());

        if (!valid) {
            $("#" + itemId + "-label").addClass("missing");
            $("#" + itemId).addClass("missingField");
            //console.log("not valid " + "#" + itemId + "-label");
        }

        return valid;
    }    
    
    function validationCharsItems(items){
        var valid = true;
        $.each(items, function(key, id) {
            if(!validationChars(id)){
                valid = false;
            }
        });
        return valid;
    }

    function validationChars(id){
        var valid = true;
        $("#" + id + "-label").removeClass("missing");
        $("#" + id).removeClass("missingField");

        var regex = /[!':?<>|@#$^&\";.\\]/;

        if (regex.test($("#" + id).val())) {
            valid = false;
        }

        if (!valid) {
            $("#" + id + "-label").addClass("missing");
            $("#" + id).addClass("missingField");
        }

        return valid;
    }

    function validationPhone(id){
        var valid = true;
        $("#" + id + "-label").removeClass("missing");
        $("#" + id).removeClass("missingField");

        //matches numbers, dashes, parentheses and space.
        var regex = /[0-9\-\(\)\s]+./;

        if (!regex.test($("#" + id).val())) {
            valid = false;
        }

        if (!valid) {
            $("#" + id + "-label").addClass("missing");
            $("#" + id).addClass("missingField");
        }

        return valid;
    }

    /**
     * Verify that a phone number contains a specifed number of digits.
     * 
     * @param {Number} number Phone number to evaluate
     * @param {Number} requiredLength required number of digits in phone number.
     * @returns {Boolean} true if numer contains number of digits equal to requiredLength.
     */
    function validationPhoneLength(number, requiredLength) {
        var clean = number.replace(/[^\d]/g, '');
        return clean.length === requiredLength;
    }

    function isNumericPrecision(items){
        var valid = true;
        $.each(items, function(key, id) {
            if(hasData($("#" + id.split("|")[0]).val())) {
                if(!isItemNumericPrecision(id.split("|")[0], id.split("|")[1])) {
                    valid = false;
                }
            }
        });
        return valid;
    }

    function isItemNumericPrecision(id, precision) {
        var valid = true;

        $("#" + id + "-label").removeClass("missing");
        $("#" + id).removeClass("missingField");
        
        var regex = new RegExp(/^\d*\.?\d*$/);
        
        if (precision === 2) {
            regex = new RegExp(/^\d*(\.\d{0,2})?$/);
        } else if (precision === 3) {
            regex = new RegExp(/^\d*(\.\d{0,3})?$/);
        } else if (precision === 4) {
            regex = new RegExp(/^\d*(\.\d{0,4})?$/);
        } else if (precision === 5) {
            regex = new RegExp(/^\d*(\.\d{0,5})?$/);
        }

        if (!regex.test($("#" + id).val())) {
            valid = false;
        }

        if (!valid) {
            $("#" + id + "-label").addClass("missing");
            $("#" + id).addClass("missingField");
        }

        return valid;
    }
    
    
    function isNumericTooBig(items){
        var valid = true;
        $.each(items, function(key, id) {
            if(hasData($("#" + id.split("|")[0]).val())) {
                if(!isItemNumericTooBig(id.split("|")[0], id.split("|")[1])) {
                    valid = false;
                }
            }
        });
        return valid;
    }

    function isItemNumericTooBig(id, size) {
        var valid = true;
        
        $("#" + id + "-label").removeClass("missing");
        $("#" + id).removeClass("missingField");
        $("#" + id + "-help").empty();

        if(parseFloat($("#" + id).val()) > size) {
            $("#" + id + "-label").addClass("missing");
            $("#" + id).addClass("missingField");
            $("#" + id + "-help").html("Must be less than " + size);
            valid = false;
        }
        return valid;
    }


    /**
    * Refresh the ssam booking item listing.
    * @param url -
    * @param soGkey -
    * @param bookingNumber -
    * */
    function refreshBookingItemsListing(url, soGkey, bookingNumber) {
        $.ajax({
            type: "POST",
            url: url,
            data:{
                method: 'refreshBookingItemsListing',
                soGkey: soGkey,
                bookingNumber: bookingNumber
            },
            success: function(data) {
                $('#bookingItemsListing', window.parent.document).html(data);
                window.parent.Shadowbox.close();
            },
            error: function(xhr, textStatus, error) {
                alert("A problem occurred: " + xhr.readyState + "-" + xhr.status + "-" + xhr.statusText + "-" + xhr.responseText + "-" + textStatus + "-" + error);
            }
        });
    }

    function isNumber(items){
        var valid = true;
        $.each(items, function(key, id) {
            if(!itemIsNumber(id)){
                valid = false;
            }
        });
        return valid;
    }

    function itemIsNumber(itemId){
        var valid = true;
        $("#" + itemId + "-label").removeClass("missing");
        if(hasData($("#" + itemId).val()) && isNaN($("#" + itemId).val())){
           valid = false;
           $("#" + itemId + "-label").addClass("missing");
        }
        return valid;
    }

    function lineCookie(lineId) {
        if(lineId.length > 0) {
            return lineId;
        } else {
            if ($.cookie('saved_line')) {
                return $.cookie('saved_line');
            }
            return '';
        }
    }
    
    function ownerCookie(owner) {
        if($.cookie('saved_owner')) {
            return $.cookie('saved_owner');
        } else {
            return owner;
        }
    }

    function quickSearchCookie(value) {
        if (value) {
            $.cookie('quick_search', value, {path: '/'});
            return value;
        }

        if($.cookie('quick_search')) {
            return $.cookie('quick_search');
        }
    }

    function preload(arrayOfImages) {
        $(arrayOfImages).each(function(){
            $('<img/>')[0].src = this;
        });
    }

    function datepickerFormat(dateFormatPref){
        if(dateFormatPref === 'yyyy/MM/dd') {
            return "yy/mm/dd";
        }
        if(dateFormatPref === 'dd/MM/yyyy') {
            return "dd/mm/yy";
        }
        return "mm/dd/yy";
    }

    /**
     * Disable one or more fields.
     * @param fields -
     */
    function disable(fields) {
        if (fields !== null) {
            for (var i = 0; i < fields.length; i++) {
                $(fields[i]).prop('disabled', true);
            }
        }
    }

    /**
     * Enable one or more fields.
     * @param fields -
     */
    function enable(fields) {
        if (fields !== null) {
            for (var i = 0; i < fields.length; i++) {
                $(fields[i]).prop('disabled', false);
            }
        }
    }

    function require2(field) {        
        if (field.type === 'text') {
            return ( $.trim($(field).val()) );
        } else if (/^select.+/.test(field.type)) {
            return ($(field).prop('selectedIndex') > 0);
        }
        return false;
    }

    /**
     * Empties and adds a prompt to a combo.  Assumes combo has already been
     * emptied.
     * @param combo -
     * @param prompt -
     */
    function comboPrompt(combo, prompt) {
        combo.html('<option>' + prompt + '</option>');
    }

    /**
     * Verifies that a field value is numeric and falls within a specific
     * range.
     * @param value -
     * @param min -
     * @param max -
     */
    function inRange(value, min, max) {
        var n = parseFloat(value);
        if (!isNaN(n)) {
            return (n >= min && n <= max);
        }
        return false;
    }

    /**
     * Used for DisplayTag result grids that have a text field for page-navigation.
     * On the keypress event, and if enter was pressed, this will simulate
     * triggering the "go" button.
     * @param e -
     */
    function navigateToPage(e) {
        if (e.keyCode === 13) {
            $('#go_Paging').trigger('click');
        }
    }

    /**
    * Method get value from textarea DOM element, split it by ',' and line break signs ('\n').
    * Return whether the amount of splitted element is in valid range (count param)
    * @param idOfTextArea - id of textarea element
    * @param count - max value
    * @return true if elements in splitted by delimeters array is less or equal count param
    **/
    function validateCount(idOfTextArea, count) {
	var arr = $("#"+idOfTextArea).val().replace(/\n+/g,",").replace(/,+/g,",").split(',');

	//if empty strings are allowed just comment this block
	arr = $.grep(arr, function(e){
            return !!$.trim(e);
	});
	//end
	return arr.length <=count;
    }

    function createNewSavedList(line, numbers) {
        var query = "";
        if (line) {
            var date = new Date();
            var listName = line + " - "  + date.getMonth() + "/" + date.getDate() + "/" + date.getFullYear();
            query += "&listName=" + encodeURIComponent(listName);
        }
        if (numbers) {
            query += "&equipmentNumbers=" + encodeURIComponent(numbers.join(","));
        }

        var url = "../myaccount/default.do?method=mySavedLists" + query;

        Shadowbox.open({
            content: url,
            player: "iframe",
            title: "Create/Edit Lists",
            width: 800,
            height: 600
        });
    }

    function loadSavedList(id, target) {
        var callbacks = $.Callbacks();
        if (typeof(loadSavedList_complete) !== 'undefined' && typeof(loadSavedList_complete) === 'function') {
            callbacks.add( loadSavedList_complete );
        }

        if(id) {
            if(id === 'new') {
                createNewSavedList();
            } else {
                $.getJSON("../ajax/default.do?method=getSavedListContent&listId=" + id, function(data) {
                    if ((data).length) {
                        var items = [];
                        $.each(data, function(key, val) {
                            items.push(val + "\n");
                        });
                        items = items.join('');
                        $(target).val(items);
                        callbacks.fire();
                    }
                });
            }
        }
    }
    
    /**
     * Hides the given Area is the Textarea has more than one element in it
     * @param textArea The Textarea that will be checked if there is more than one element
     * @param areaToHide The area that will be hidden, if textarea has more than one element
     */
    function hideAreaIfTextareaMoreThanOne(textArea, areaToHide) {
        var numberCount = textArea.val().replace(/\n+/g,",").split(',').filter(function(e){return e;}).length;
        if(numberCount > 1) {
            areaToHide.addClass('hidden');
        } else {
            areaToHide.removeClass('hidden');
        }
    }
    
    function toggleDetails(item) {
        var showing = $("#" + item).is(":visible");
        if(showing) {
            $("#" + item).hide();
            $("#" + item + "-label").html("<i class=\"fa fa-caret-right\" aria-hidden=\"true\"></i> Show details");
        } else {
            $("#" + item).show();
            $("#" + item + "-label").html("<i class=\"fa fa-caret-down\" aria-hidden=\"true\"></i> Hide details");
        }
    }
    
    /**
     * Opens a modal window containing a list of unacknowledged notifications.
     */
    function openNotificationsModal() {

        if ($("#alertCount").data("alert-count") !== 0) {
            $("body").append('<div id="notificationsModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="businessTypeModalLabel">Loading Notifications....</div>');

            $("#notificationsModal").modal();

            //When the notifications window is closed, send the associated gkey set to the
            //server where they can be marked as viewed.
            $("#notificationsModal").on('hidden.bs.modal', function() {
                var notifGkeys = $("div[data-notif-gkey]").map(function() {
                        return $(this).data("notif-gkey");
                    });

                //Remove the DOM node associated with the modal.
                $("#notificationsModal").remove();

                $("#alertMenu").load("../ajax/default.do", {method: 'notificationAck', gkeys: notifGkeys.get().join()});

            });

            $("#notificationsModal").modal('show');
            $("#notificationsModal").load("../ajax/default.do?method=notifications");
        }
        
    }
    
//</script>