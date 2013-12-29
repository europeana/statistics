<?php

/** Absolute path where image will be uploaded **/
$uploadFolder = __DIR__ . '/data/';

/** For img src field **/
$imgsrc = 'data/';

/** Ajax response **/
$response = array();

if (isset($_FILES['file'])) {
    $file = $_FILES['file'];
    $filename = uniqid() . '-' . (pathinfo($file['name'], PATHINFO_EXTENSION) ? : 'png');

    move_uploaded_file($file['tmp_name'], $uploadFolder . $filename);

    $response['filename'] = $imgsrc . $filename;

} else {
    $response['error'] = 'Error while uploading file';
}

echo json_encode($response);
?>