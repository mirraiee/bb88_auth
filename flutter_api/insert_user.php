<?php
include 'db_config.php';

$username = $_POST['username'];
$email = $_POST['email'];
$password = password_hash($_POST['password'], PASSWORD_BCRYPT);

$sql = "INSERT INTO users (name, email, password) VALUES ('$username', '$email', '$password')";

if($conn -> query($sql) === TRUE){
    echo json_encode(['message' => 'User created successfully']);
}else{
    echo json_encode(['message' => $conn -> error]);
}

?>