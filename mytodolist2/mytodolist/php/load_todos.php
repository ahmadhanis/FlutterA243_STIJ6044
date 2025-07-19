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
//step 1
$results_per_page = 10;
//step 2
if ( isset( $_GET[ 'pageno' ] ) ) {
    $pageno = ( int )$_GET[ 'pageno' ];
} else {
    $pageno = 1;
}
//step 3
$page_first_result = ( $pageno - 1 ) * $results_per_page;

$sqlloadtodos = "SELECT * FROM `tbl_todos` WHERE `user_id` = '$userid' ORDER BY `tbl_todos`.`date_create` DESC";
$result = $conn->query( $sqlloadtodos );

//step 4 pagination
$number_of_result = $result->num_rows;
$number_of_page = ceil( $number_of_result / $results_per_page );

//step 5 pagination
$sqlloadtodos = $sqlloadtodos ." LIMIT " . $page_first_result . ',' . $results_per_page;

$result = $conn->query( $sqlloadtodos );

if ( $result->num_rows > 0 ) {
    $sentArray = array();
    while ( $row = $result->fetch_assoc() ) {
        $sentArray[] = $row;
    }
    $response = array( 'status' => 'success', 'data' =>  $sentArray,'number_of_result' => $number_of_result,'number_of_page' => $number_of_page, 'current_page' => $pageno );
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
