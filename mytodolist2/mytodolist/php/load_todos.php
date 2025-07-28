<?php
error_reporting( 0 );
header( 'Access-Control-Allow-Origin: *' );

if ( !isset( $_GET[ 'userid' ] ) ) {
    sendJsonResponse( [ 'status' => 'failed', 'data' => null ] );
    die;
}

include_once( 'dbconnect.php' );

$userid = $_GET[ 'userid' ];
$results_per_page = 10;
$pageno = isset( $_GET[ 'pageno' ] ) ? ( int )$_GET[ 'pageno' ] : 1;
$page_first_result = ( $pageno - 1 ) * $results_per_page;

// Optional filters
$month = isset( $_GET[ 'month' ] ) ? ( int )$_GET[ 'month' ] : 0;
$year = isset( $_GET[ 'year' ] ) ? ( int )$_GET[ 'year' ] : 0;
$search = isset( $_GET[ 'search' ] ) ? $conn->real_escape_string( trim( $_GET[ 'search' ] ) ) : '';

// Build WHERE clause
$whereClause = "WHERE `user_id` = '$userid'";

// If search is provided, override other filters
if ( !empty( $search ) ) {
    $whereClause .= " AND (`todo_title` LIKE '%$search%' OR `todo_desc` LIKE '%$search%')";
} else if ( $month > 0 && $year > 0 ) {
    $whereClause .= " AND MONTH(`todo_date`) = $month AND YEAR(`todo_date`) = $year";
}

// Step 1: Count query for pagination
$countQuery = "SELECT COUNT(*) AS total FROM `tbl_todos` $whereClause";
$countResult = $conn->query( $countQuery );
$row = $countResult->fetch_assoc();
$number_of_result = ( int )$row[ 'total' ];
$number_of_page = ceil( $number_of_result / $results_per_page );

// Step 2: Data query with limit
$dataQuery = "SELECT * FROM `tbl_todos` $whereClause ORDER BY `date_create` DESC LIMIT $page_first_result, $results_per_page";
$result = $conn->query( $dataQuery );

if ( $result->num_rows > 0 ) {
    $sentArray = [];
    while ( $row = $result->fetch_assoc() ) {
        $sentArray[] = $row;
    }
    sendJsonResponse( [
        'status' => 'success',
        'data' => $sentArray,
        'number_of_result' => $number_of_result,
        'number_of_page' => $number_of_page,
        'current_page' => $pageno
    ] );
} else {
    sendJsonResponse( [ 'status' => 'failed', 'data' => null ] );
}

function sendJsonResponse( $response ) {
    header( 'Content-Type: application/json' );
    echo json_encode( $response );
}
?>
