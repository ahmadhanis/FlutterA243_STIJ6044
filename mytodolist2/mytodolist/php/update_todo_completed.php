<?php
error_reporting( 0 );
header( 'Access-Control-Allow-Origin: *' );
include_once( 'dbconnect.php' );

$todoId = $_POST[ 'todo_id' ];
$userId = $_POST[ 'user_id' ];
$completed = $_POST[ 'completed' ];

$sql = "UPDATE tbl_todos SET todo_completed = '$completed' WHERE todo_id = '$todoId' AND user_id = '$userId'";

if ( $conn->query( $sql ) === TRUE ) {
    echo json_encode( [ 'status' => 'success' ] );
} else {
    echo json_encode( [ 'status' => 'error' ] );
}
?>
