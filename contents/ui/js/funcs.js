// Adds 'a' days to the current date and returns the day of the week
function addDay(a) {
    var dateActual = new Date();
    dateActual.setDate(dateActual.getDate() + a);
    var dateFormatted = Qt.formatDateTime(dateActual, "dddd");
    console.log("Date with one day added:", dateFormatted);
    return dateFormatted;
}
