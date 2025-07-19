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

$todoid = $_POST[ 'todo_id' ];
$userid = $_POST[ 'user_id' ];


$sqldelete = "DELETE FROM `tbl_todos` WHERE `todo_id` = '$todoid' AND `user_id` = '$userid';";
try {
    if ( $conn->query( $sqldelete ) === TRUE ) {
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
