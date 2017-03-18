function showFeedbackForm() {
    console.log("Showing feedback form")
    var form = document.getElementById("feedbackForm");
    form.style.display = 'block';
} 

function hideFeedbackForm() {
    console.log("Cancelled feedback form")
    var form = document.getElementById("feedbackForm");
    form.style.display = 'none';
}
