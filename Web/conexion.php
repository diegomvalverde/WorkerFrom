<?php
header('Access-Control-Allow-Origin: *'); // Without this the htmls doesn't work

try
{
  $connectionOpen = false;
  // Opening sqlserver connection
  $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
  $conectionInfo = array("Database"=>'WorkerForm', "UID"=>"user", "PWD"=>"userpass", "CharacterSet"=>"UTF-8");
  $conn_sis = sqlsrv_connect($servername, $conectionInfo);
  if($conn_sis)
  {
    $connectionOpen = true;
  }
  else
  {
      die(print_r(sqlsrv_errors(), true));
  }
}
catch(Exception $e)
{
  $connectionOpen = false;
}
// Asking for function id and if connection to sql is open
if(isset($_POST['functionID']) and $connectionOpen)
{
  $function = $_POST['functionID'];

  if($function == 1)
  {
    $valorDocID = $_POST['valorDocID'];
    login();
  }
  else
  {
    echo 0;
  }
}
else if(!$connectionOpen)
{
  echo -1;
}


// Function to login on sqlserver

function login($valorDocID)
{
  $output = 0;
  $sql = "{call wfsp_login(?,?)}";
  $params = array
  (
  array($valorDocID,SQLSRV_PARAM_IN),
  array(&$outSeq, SQLSRV_PARAM_INOUT)
  );

  // Sending parameters to sql (stored procedure)
  $stmt = sqlsrv_query($conn_sis, $sql, $params) or die(print_r(sqlsrv_errors(),true));
  if( $stmt === false )
  {
  die( print_r( sqlsrv_errors(), true));
  }

  sqlsrv_next_result($stmt);
  sqlsrv_close($conn_sis);
  return $outSeq;
}


//
// // Funcion para cargar los ultimos estados de cuenta de  una cuenta dada
// function estadosCuenta($param1)
// {
//   $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
//   $conectionInfo = array("Database"=>'BankAccount', "UID"=>"user", "PWD"=>"userpass", "CharacterSet"=>"UTF-8");
//   $conn_sis = sqlsrv_connect($servername, $conectionInfo);
//
//   if($conn_sis)
//   {
//     // echo "Coneccion exitosa";
//   }
//   else
//   {
//       die(print_r(sqlsrv_errors(), true));
//   }
//
//   $outSeq="";
//   $sql = "{call casp_estadocuenta(?,?)}";
//   $params = array
//   (
//   array($param1,SQLSRV_PARAM_IN),
//   array(&$outSeq, SQLSRV_PARAM_INOUT)
//   );
//
//   $stmt = sqlsrv_query($conn_sis, $sql, $params) or die(print_r(sqlsrv_errors(),true));
//
//
//   if( $stmt === false )
//   {
//   // echo "Error in executing statement 3.\n";
//   die( print_r( sqlsrv_errors(), true));
//   }
//
//   sqlsrv_next_result($stmt);
//   sqlsrv_close($conn_sis);
//   return $outSeq;
// }
//
//
//
// // Funcion para consultar clientes en la base de datos.
// function consultarUsuario($param1, $param2)
// {
//   $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
//   $conectionInfo = array("Database"=>'BankAccount', "UID"=>"user", "PWD"=>"userpass", "CharacterSet"=>"UTF-8");
//   $conn_sis = sqlsrv_connect($servername, $conectionInfo);
//
//   if($conn_sis)
//   {
//     // echo "Conexion exitosa";
//   }
//   else
//   {
//       die(print_r(sqlsrv_errors(), true));
//   }
//
//   $outSeq=-1;
//   $sql = "{call casp_consultausuario(?,?,?)}";
//   $params = array
//   (
//   array($param1,SQLSRV_PARAM_IN),
//   array($param2, SQLSRV_PARAM_IN),
//   array(&$outSeq, SQLSRV_PARAM_INOUT)
//   );
//
//   $stmt = sqlsrv_query($conn_sis, $sql, $params) or die(print_r(sqlsrv_errors(),true));
//
//   if( $stmt === false )
//   {
//   // echo "Error in executing statement 3.\n";
//   die( print_r( sqlsrv_errors(), true));
//   }
//
//   sqlsrv_next_result($stmt);
//   sqlsrv_close($conn_sis);
//   return $outSeq;
//
// }
//
// function agregarMovimiento($param1, $param2, $param3)
// {
//   $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
//   $conectionInfo = array("Database"=>'BankAccount', "UID"=>"user", "PWD"=>"userpass", "CharacterSet"=>"UTF-8");
//   $conn_sis = sqlsrv_connect($servername, $conectionInfo);
//
//   if($conn_sis)
//   {
//     // echo "Coneccion exitosa";
//   }
//   else
//   {
//       die(print_r(sqlsrv_errors(), true));
//   }
//
//   $outSeq = -1;
//   $sql = "{call casp_movimiento(?,?,?,?)}";
//   $params = array
//   (
//   array($param1,SQLSRV_PARAM_IN),
//   array($param2, SQLSRV_PARAM_IN),
//   array($param3, SQLSRV_PARAM_IN),
//   array(&$outSeq, SQLSRV_PARAM_INOUT)
//   );
//
//   $stmt = sqlsrv_query($conn_sis, $sql, $params) or die(print_r(sqlsrv_errors(),true));
//
//
//   if( $stmt === false )
//   {
//   // echo "Error in executing statement 3.\n";
//   die( print_r( sqlsrv_errors(), true));
//   }
//   sqlsrv_next_result($stmt);
//   sqlsrv_close($conn_sis);
//   return $outSeq;
// }
//
//
// function insertarCuenta($param1, $param2)
// {
//   $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
//   $conectionInfo = array("Database"=>'BankAccount', "UID"=>"user", "PWD"=>"userpass", "CharacterSet"=>"UTF-8");
//   $conn_sis = sqlsrv_connect($servername, $conectionInfo);
//
//   if($conn_sis)
//   {
//     // echo "Coneccion exitosa";
//   }
//   else
//   {
//       die(print_r(sqlsrv_errors(), true));
//   }
//
//   $outSeq = -1;
//   $sql = "{call casp_agregarcuenta(?,?,?)}";
//
//   $params = array
//   (
//   array($param1,SQLSRV_PARAM_IN),
//   array($param2, SQLSRV_PARAM_IN),
//   array(&$outSeq, SQLSRV_PARAM_INOUT)
//   );
//
//   $stmt = sqlsrv_query($conn_sis, $sql, $params) or die(print_r(sqlsrv_errors(),true));
//
//
//   if( $stmt === false )
//   {
//   // echo "Error in executing statement 3.\n";
//   die( print_r( sqlsrv_errors(), true));
//   }
//
//   sqlsrv_next_result($stmt);
//   sqlsrv_close($conn_sis);
//   return $outSeq;
// }
//

?>
