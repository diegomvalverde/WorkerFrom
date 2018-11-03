<?php
// header('Access-Control-Allow-Origin: *'); // Sin esto mueren los html xD
// // Check if the form is submitted chequear si el post fue hecho
//
//
// if(isset($_POST["usr"]) and isset($_POST["pwd"]))
// {
//   $usuario = $_POST['usr'];
//   $contra  = $_POST['pwd'];
//   echo consultarUsuario($usuario, $contra);
// }
// elseif((isset($_POST["clientName"]) and $_POST["clientName"] != "") and (isset($_POST["clientId"]) and $_POST["clientId"]) and
//         (isset($_POST["clientPassword"]) and $_POST["clientPassword"]))
// {
//   $userName = $_POST['clientName'];
//   $userId = $_POST['clientId'];
//   $userPassword = $_POST['clientPassword'];
//   echo insertarCliente($userId, $userName, $userPassword);
// }
// elseif((isset($_POST["accountType"]) and $_POST["accountType"] != "") and (isset($_POST["ownerId"]) and $_POST["ownerId"] != ""))
// {
//   $userId = $_POST['ownerId'];
//   $accountType = $_POST['accountType'];
//   echo insertarCuenta($userId, $accountType);
// }
// elseif((isset($_POST["movType"]) and $_POST["movType"] != "") and (isset($_POST["addressee"]) and $_POST["addressee"] != "") and (isset($_POST["moneyPush"]) and $_POST["moneyPush"] != ""))
// {
//   $addressee = $_POST['addressee'];
//   $money = $_POST['moneyPush'];
//   $movType = $_POST['movType'];
//   if($movType == 1 or $movType == 2 or $movType == 3 or $movType == 4)
//   {
//   echo agregarMovimiento($addressee, $money, $money);
//   }
//   else
//   {
//     echo -1;
//   }
// }
// elseif((isset($_POST["accountId"]) and $_POST["accountId"] != ""))
// {
//   $accountId = $_POST['accountId'];
//   echo estadosCuenta($accountId);
// }
// else
// {
//   echo 0;
// }
echo $_POST["functionID"]

// Funciones para llamar a procedimoento almacenados

function insertarCliente($param1, $param2, $param3)
{
  $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
  $conectionInfo = array("Database"=>'BankAccount', "UID"=>"user", "PWD"=>"userpass", "CharacterSet"=>"UTF-8");
  $conn_sis = sqlsrv_connect($servername, $conectionInfo);

  if($conn_sis)
  {
    // echo "Coneccion exitosa";
  }
  else
  {
      die(print_r(sqlsrv_errors(), true));
  }

  $outSeq=-1;
  $sql = "{call casp_agregarcliente(?,?,?,?)}";
  $params = array
  (
  array($param1,SQLSRV_PARAM_IN),
  array($param2, SQLSRV_PARAM_IN),
  array($param3, SQLSRV_PARAM_IN),
  array(&$outSeq, SQLSRV_PARAM_INOUT)
  );

  $stmt = sqlsrv_query($conn_sis, $sql, $params) or die(print_r(sqlsrv_errors(),true));


  if( $stmt === false )
  {
  // echo "Error in executing statement 3.\n";
  die( print_r( sqlsrv_errors(), true));
  }

  sqlsrv_next_result($stmt);
  sqlsrv_close($conn_sis);
  return $outSeq;

}

// Funcion para cargar los ultimos estados de cuenta de  una cuenta dada
function estadosCuenta($param1)
{
  $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
  $conectionInfo = array("Database"=>'BankAccount', "UID"=>"user", "PWD"=>"userpass", "CharacterSet"=>"UTF-8");
  $conn_sis = sqlsrv_connect($servername, $conectionInfo);

  if($conn_sis)
  {
    // echo "Coneccion exitosa";
  }
  else
  {
      die(print_r(sqlsrv_errors(), true));
  }

  $outSeq="";
  $sql = "{call casp_estadocuenta(?,?)}";
  $params = array
  (
  array($param1,SQLSRV_PARAM_IN),
  array(&$outSeq, SQLSRV_PARAM_INOUT)
  );

  $stmt = sqlsrv_query($conn_sis, $sql, $params) or die(print_r(sqlsrv_errors(),true));


  if( $stmt === false )
  {
  // echo "Error in executing statement 3.\n";
  die( print_r( sqlsrv_errors(), true));
  }

  sqlsrv_next_result($stmt);
  sqlsrv_close($conn_sis);
  return $outSeq;
}



// Funcion para consultar clientes en la base de datos.
function consultarUsuario($param1, $param2)
{
  $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
  $conectionInfo = array("Database"=>'BankAccount', "UID"=>"user", "PWD"=>"userpass", "CharacterSet"=>"UTF-8");
  $conn_sis = sqlsrv_connect($servername, $conectionInfo);

  if($conn_sis)
  {
    // echo "Conexion exitosa";
  }
  else
  {
      die(print_r(sqlsrv_errors(), true));
  }

  $outSeq=-1;
  $sql = "{call casp_consultausuario(?,?,?)}";
  $params = array
  (
  array($param1,SQLSRV_PARAM_IN),
  array($param2, SQLSRV_PARAM_IN),
  array(&$outSeq, SQLSRV_PARAM_INOUT)
  );

  $stmt = sqlsrv_query($conn_sis, $sql, $params) or die(print_r(sqlsrv_errors(),true));

  if( $stmt === false )
  {
  // echo "Error in executing statement 3.\n";
  die( print_r( sqlsrv_errors(), true));
  }

  sqlsrv_next_result($stmt);
  sqlsrv_close($conn_sis);
  return $outSeq;

}

function agregarMovimiento($param1, $param2, $param3)
{
  $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
  $conectionInfo = array("Database"=>'BankAccount', "UID"=>"user", "PWD"=>"userpass", "CharacterSet"=>"UTF-8");
  $conn_sis = sqlsrv_connect($servername, $conectionInfo);

  if($conn_sis)
  {
    // echo "Coneccion exitosa";
  }
  else
  {
      die(print_r(sqlsrv_errors(), true));
  }

  $outSeq = -1;
  $sql = "{call casp_movimiento(?,?,?,?)}";
  $params = array
  (
  array($param1,SQLSRV_PARAM_IN),
  array($param2, SQLSRV_PARAM_IN),
  array($param3, SQLSRV_PARAM_IN),
  array(&$outSeq, SQLSRV_PARAM_INOUT)
  );

  $stmt = sqlsrv_query($conn_sis, $sql, $params) or die(print_r(sqlsrv_errors(),true));


  if( $stmt === false )
  {
  // echo "Error in executing statement 3.\n";
  die( print_r( sqlsrv_errors(), true));
  }
  sqlsrv_next_result($stmt);
  sqlsrv_close($conn_sis);
  return $outSeq;
}


function insertarCuenta($param1, $param2)
{
  $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
  $conectionInfo = array("Database"=>'BankAccount', "UID"=>"user", "PWD"=>"userpass", "CharacterSet"=>"UTF-8");
  $conn_sis = sqlsrv_connect($servername, $conectionInfo);

  if($conn_sis)
  {
    // echo "Coneccion exitosa";
  }
  else
  {
      die(print_r(sqlsrv_errors(), true));
  }

  $outSeq = -1;
  $sql = "{call casp_agregarcuenta(?,?,?)}";

  $params = array
  (
  array($param1,SQLSRV_PARAM_IN),
  array($param2, SQLSRV_PARAM_IN),
  array(&$outSeq, SQLSRV_PARAM_INOUT)
  );

  $stmt = sqlsrv_query($conn_sis, $sql, $params) or die(print_r(sqlsrv_errors(),true));


  if( $stmt === false )
  {
  // echo "Error in executing statement 3.\n";
  die( print_r( sqlsrv_errors(), true));
  }

  sqlsrv_next_result($stmt);
  sqlsrv_close($conn_sis);
  return $outSeq;
}


?>
