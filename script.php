<?php
     $serverName = getenv('SQL_ServerName'); // update me
     $connectionOptions = array(
         "Database" => getenv('SQL_DatabaseName'), // update me
         "UID" => getenv('SQL_Username'), // update me
         "PWD" => getenv('SQL_Password') // update me
     );
      //Establishes the connection
      $conn = sqlsrv_connect($serverName, $connectionOptions);
      $tsql1= "SELECT [Name], [LastName] FROM [dbo].[INFO]";
      $tsql2 = "INSERT INTO dbo.Log (Description) VALUES ('Function executed successfully.')";
      $getResults= sqlsrv_query($conn, $tsql1);
      if ($getResults == FALSE)
           echo (sqlsrv_errors());

      $message = '';
      $result = '';
      while ($row = sqlsrv_fetch_array($getResults, SQLSRV_FETCH_ASSOC)) {
        $message = ($row['Name'] . " " . $row['LastName'] . PHP_EOL);
        $result = $message . ' ' . $result;
      }
      header('Content-type: application/json');
      http_response_code(200);
      echo json_encode([
            "Outputs" => [
                "message" => $result,
                "res" => [
                    "statusCode" => 200,
                    "body" => $result
                ]
            ],
            "Logs" => [
                "Request completed"
            ]
        ]);
      sqlsrv_query($conn,$tsql2);
     
      sqlsrv_free_stmt($getResults);
?>