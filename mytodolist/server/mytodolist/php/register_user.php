<?php
// error_reporting( 0 );
header( 'Access-Control-Allow-Origin: *' );
// running as crome app

include_once( 'dbconnect.php' );

if ( !isset( $_POST[ 'email' ] ) || !isset( $_POST[ 'password' ] ) ) {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
    die;
}

$email = $_POST[ 'email' ];
$password = sha1( $_POST[ 'password' ] );

$sqlinsert = "INSERT INTO `tbl_users`(`user_email`, `user_password`) VALUES ('$email','$password')";

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
