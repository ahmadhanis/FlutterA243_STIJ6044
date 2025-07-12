<?php
error_reporting( 0 );
header( 'Access-Control-Allow-Origin: *' );
// running as crome app

if ( !isset( $_GET[ 'userid' ] ) ) {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
    die;
}

include_once( 'dbconnect.php' );

$userid = $_GET[ 'userid' ];

$sqlloadtodos = "SELECT * FROM `tbl_todos` WHERE `user_id` = '$userid' ORDER BY `tbl_todos`.`date_create` DESC";
$result = $conn->query( $sqlloadtodos );
if ( $result->num_rows > 0 ) {
    $sentArray = array();
    while ( $row = $result->fetch_assoc() ) {
        $sentArray[] = $row;
    }
    $response = array( 'status' => 'success', 'data' =>  $sentArray );
    sendJsonResponse( $response );
} else {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
}

function sendJsonResponse( $response )
 {
    header( 'Content-Type: application/json' );
    echo json_encode( $response );
}

?>
