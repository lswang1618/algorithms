function setLoadingText() {
    // Set up some loading text, since I haven't been able to get around the slow db load for now
    var completeCalled = false;
    $("html, body").animate({
        scrollTop: "0px"
    }, {
        complete: function() {
            if (!completeCalled) {
                completeCalled = true;
            }
        }
    });

    $("#data-display").slideUp("fast", function() {
        if ($(".dashboard-title-2")) {
            $(".dashboard-title-2").remove();
        }
        if ($(".data-summary")) {
            $(".data-summary").remove();
        }
        if ($(".data")) {
            $(".data").remove();
        }
        var question_text = document.createElement("h3");
        question_text.className = "dashboard-title-2";
        question_text.innerHTML = "Loading...";
        var summary_table_title = document.getElementById("summary_table_title");
        summary_table_title.appendChild(question_text);
    });
    $("#data-display").slideDown('fast');
}

function displayResponseTable(question, responses, choices, readers) {

    $("#data-display").hide('slow', function() {
        renderResponseTable(question, responses, choices, readers);
    });
    $("#data-display").slideDown('slow');
}

// Show the question data
function renderResponseTable(question, responses, choices, readers) {

    // Remove previously created divs
    // $("#data-display").slideUp()
    $(".dashboard-title-2").remove()
    $(".data-summary").remove()
    $(".data").remove()

    //Display question above table
    var question_text = document.createElement("h3");
    question_text.className = "dashboard-title-2";
    question_text.innerHTML = question;
    var summary_table_title = document.getElementById("summary_table_title");
    summary_table_title.appendChild(question_text);

    if (choices.length > 0) {
        var choice_list = document.createElement("h3");
        choice_list.innerHTML = choices;
        var str = '';

        var body = document.body,
            data_summary_table = document.createElement('table');
        data_summary_table.className = "data-summary";

        //Create table caption
        // var caption = data_summary_table.createCaption();
        // caption.innerHTML = "Data summary";

        // Count the number of responses per choice
        // Stupid, but quick to code (and not quick to run...it's n+m time :|)
        // create a map so we don't have to look up ids repeatedly

        number_responses_per_choice = {};
        for (var i = 0; i < choices.length; i++)
            number_responses_per_choice[choices[i].id] = 0;

        // go through all responses and tally
        for (var i = 0; i < responses.length; i++)
            number_responses_per_choice[responses[i].choice_id]++;

        for (var i = 0; i < choices.length; i++) {
            var tr = data_summary_table.insertRow();
            var td = tr.insertCell();
            td.appendChild(document.createTextNode(choices[i].text));
            //Add a count of number of responses
            var td2 = tr.insertCell();
            td2.appendChild(document.createTextNode(number_responses_per_choice[choices[i].id]));
            var td3 = tr.insertCell();

            //Add a horizontal bar graph
            var div = document.createElement("div");
            div.className = ('bar');
            // Set width as a fraction of total votes only if there are votes
            if (responses.length > 0) {
                div.style.width = (200 * number_responses_per_choice[choices[i].id]) / responses.length + "px";
                div.style.background = "#12c99c";
                td3.appendChild(div);
                //Add percentage
                td3.appendChild(document.createTextNode(Math.round(100 * number_responses_per_choice[choices[i].id] / responses.length) + " %"));

            }
        }

        var header = data_summary_table.createTHead();
        var row = header.insertRow(0);
        var cell = row.insertCell(0);
        var cell2 = row.insertCell(1);
        var cell3 = row.insertCell(2);
        cell.innerHTML = "Options";
        cell2.innerHTML = "Responses";
        if (responses.length > 0) {
            cell3.innerHTML = "Percentage";
        }
        var answers = document.getElementById("data_summary_table");
        answers.appendChild(data_summary_table);
    }

    //Show the detailed question response data
    if (responses.length > 0) {

        // map responses to readers so we know which belong to which
        // order matters
        // responses.sort(function(a,b){return a.reader_id - b.reader_id});
        // readers.sort(function(a,b){return a.id - b.id});
        // // now that they match in order, transer creation times so that readers can be correctly sorted
        // for (var i = 0; i < responses.length; i++)
        //     readers[i]["response_created_at"] = responses[i].created_at;
        // responses.sort(function(a,b){return new Date(b.created_at) - new Date(a.created_at)}); // reverse time order
        // readers.sort(function(a,b){return new Date(b.response_created_at) - new Date(a.response_created_at)});
        // ----------NEVER MIND, I moved it to the rails query at the bottom-----------------------

        // Create CSV
        var csv_string = 'Response,Article,Time,Age,Gender\r\n';
        for (var i = 0; i < responses.length; i++) { // iterate through all responses
            var line = responses[i].text.replace(',', '(comma)') + ','; // text of responses
            line += responses[i].article_url + ','; // article where answered
            line += responses[i].created_at + ','; // time of response
            if (readers[i].age !== null) // age of responder
                line += readers[i].age + ',';
            else line += "Unknown,";
            if (readers[i].gender !== null) // gender of responder
                line += readers[i].gender + ',';
            else line += "Unknown,";
            csv_string += line + '\r\n';
        }
        download_link = document.createElement('a');
        download_link.textContent = 'Download full list of responses as CSV';
        download_link.download = "ht_responses.csv";
        download_link.href = 'data:text/csv;charset=utf-8,' + escape(csv_string);
        download_link.className = "data";

        var body = document.body,
            tbl = document.createElement('table');
        tbl.className = "data";
        var caption = tbl.createCaption();
        caption.innerHTML = "<b>Responses</b>";
        for (var i = 0; i < responses.length; i++) {
            var tr = tbl.insertRow();
            var td = tr.insertCell();
            td.appendChild(document.createTextNode(responses[i].text));
            var td2 = tr.insertCell();
            td2.appendChild(document.createTextNode(responses[i].article_url));
        }
        //The following code displays the table of data that's contained in the CSV.
        // var header = tbl.createTHead();
        // var row = header.insertRow(0);
        // var cell = row.insertCell(0);
        // var cell2 = row.insertCell(1);
        // cell2.innerHTML = "<b>Article URL</b>"
        // cell.innerHTML = "<b>Response</b>";
        // var answers = document.getElementById("answers");
        // answers.appendChild(tbl);
        answers.appendChild(download_link);
    } else {
        var text = document.createElement("h3");
        text.className = "data";
        text.innerHTML = "No Responses Yet";
        text.style.marginTop = '17px';
        var answers = document.getElementById("answers");
        answers.appendChild(text);
    }
}
