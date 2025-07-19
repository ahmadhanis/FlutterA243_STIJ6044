<?php
error_reporting( 0 );
header( 'Access-Control-Allow-Origin: *' );
// running as crome app

if ( !isset( $_POST ) ) {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
    die;
}

include_once( 'dbconnect.php' );
$todoid = $_POST[ 'todo_id'];
$email = $_POST[ 'email' ];
$userid = $_POST[ 'userid' ];
$title = $_POST[ 'title' ];
$description = $_POST[ 'description' ];
$date = $_POST[ 'date' ];
$category = $_POST[ 'category' ];
$priority = $_POST[ 'priority' ];
$completed = $_POST[ 'completed' ];
$reminderEnabled = $_POST[ 'reminder_enabled' ];

$sqlupdate = "UPDATE `tbl_todos` SET `todo_title`='$title',`todo_desc`='$description',`todo_category`='$category',`todo_date`='$date',`todo_priority`='$priority',`todo_completed`='$completed',`todo_reminder`='$reminderEnabled' WHERE `todo_id` = '$todoid';";

try {
    if ( $conn->query( $sqlupdate ) === TRUE ) {
        $response = array( 'status' => 'success', 'data' => null );
        sendJsonResponse( $response );
    } else {
        $response = array( 'status' => 'failed', 'data' => null );
        sendJsonResponse( $response );
    }

} catch ( Exception $e ) {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
    die;
}

function sendJsonResponse( $sentArray )
 {
    header( 'Content-Type: application/json' );
    echo json_encode( $sentArray );
}

?>
