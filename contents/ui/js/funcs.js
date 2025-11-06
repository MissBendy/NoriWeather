// Adds 'a' days to the current date and returns the day of the week
function sumarDia(a) {
    var fechaActual = new Date();
    fechaActual.setDate(fechaActual.getDate() + a);
    var fechaFormateada = Qt.formatDateTime(fechaActual, "dddd");
    console.log("Fecha con un día añadido:", fechaFormateada);
    return fechaFormateada;
}
