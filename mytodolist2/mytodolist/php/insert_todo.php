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

$email = $_POST[ 'email' ];
$userid = $_POST[ 'userid' ];
$title = $_POST[ 'title' ];
$description = $_POST[ 'description' ];
$date = $_POST[ 'date' ];
$category = $_POST[ 'category' ];
$priority = $_POST[ 'priority' ];
$completed = $_POST[ 'completed' ];
$reminderEnabled = $_POST[ 'reminder_enabled' ];

$sqlinsert = "INSERT INTO `tbl_todos`(`user_id`, `todo_title`, `todo_desc`, `todo_category`, `todo_date`, `todo_priority`, `todo_completed`, `todo_reminder`) VALUES ('$userid', '$title', '$description', '$category', '$date', '$priority', '$completed', '$reminderEnabled')";
// $response = array( 'status' => 'success', 'sql' => $sqlinsert );
// sendJsonResponse( $response );
try {
    if ( $conn->query( $sqlinsert ) === TRUE ) {
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
