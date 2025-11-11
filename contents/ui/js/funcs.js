// Adds a given number of days to the current date and returns the weekday name
function addDay(a) {
    // Get the current date and time
    var dateActual = new Date();

    // Advance the date by 'a' days
    dateActual.setDate(dateActual.getDate() + a);

    // Format the new date into the day of the week (e.g., Monday, Tuesday)
    var dateFormatted = Qt.formatDateTime(dateActual, "dddd");

    // Log the formatted result for debugging
    console.log("Date with one day added:", dateFormatted);

    // Return the weekday name as a string
    return dateFormatted;
}
