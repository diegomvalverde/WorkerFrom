<?php
//header('Access-Control-Allow-Origin: *'); // Sin esto mueren los html xD
// Check if the form is submitted chequear si el post fue hecho

// Asking for function id and if connection to sql is open
//echo estados("1702444511");

// log in
if(isset($_POST["valorDocID"]) and $_POST["valorDocID"] != "")
{
    $valorDocId = $_POST['valorDocID'];
    echo consultarUsuario($valorDocId);
}
// Consult deduction, bonus and value per hour
if((isset($_POST["valorDocIDQuery"])) and $_POST["valorDocIDQuery"] != "")
{
    $valorDocId = $_POST['valorDocIDQuery'];
    echo $valorDocId;
//    echo estados($userId);
}
// edit dedution
if((isset($_POST["idDeduction"])) and $_POST["idDeduction"] != "" and (isset($_POST["deductionAmount"])) and $_POST["deductionAmount"] != "")
{
    // Editar deducción
    $idDeduction = $_POST['idDeduction'];
    $deductionAmount = $_POST['deductionAmount'];
    echo $idDeduction + $deductionAmount;
//    echo estados($userId);
}
// ediat bonus
if((isset($_POST["idBonus"])) and $_POST["idBonus"] != "" and (isset($_POST["bonusAmount"])) and $_POST["bonusAmount"] != "")
{
    // Editar deducción
    $idBonus = $_POST['idBonus'];
    $bonusAmount = $_POST['bonusAmount'];
    echo $idBonus + $bonusAmount;
//    echo estados($userId);
}
// edit el valor por hora de un empleado
if((isset($_POST["idEmployeeValue"])) and $_POST["idEmployeeValue"] != "" and (isset($_POST["valueEmployee"])) and $_POST["valueEmployee"] != "")
{
    // Editar deducción
    $idEmployeeValue = $_POST['idEmployeeValue'];
    $valueEmployee = $_POST['valueEmployee'];
    echo $idEmployeeValue + $valueEmployee;
//    echo estados($userId);
}
//if((isset($_POST["idEmployeeValue"])) and $_POST["idEmployeeValue"] != "" and (isset($_POST["valueEmployee"])) and $_POST["valueEmployee"] != "")
//{
//    // Editar deducción
//    $idEmployeeValue = $_POST['idEmployeeValue'];
//    $valueEmployee = $_POST['valueEmployee'];
//    echo $i
////    echo estados($userId);
//}
if(isset($_POST["idemployeeJob"]) and $_POST["idemployeeJob"] != "")
{
    $idEmployee = $_POST['idemployeeJob'];
    echo $idEmployee;
//    echo consultarUsuario($valorDocId);
}
//else
//{
//    echo -1;
//}

// Funcion para cargar los ultimos estados de cuenta de  una cuenta dada
function estados($param1)
{
    $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
    $conectionInfo = array("Database"=>"WorkerForm", "UID"=>"user", "PWD"=>"password", "CharacterSet"=>"UTF-8");
    $conn_sis = sqlsrv_connect($servername, $conectionInfo);

  if($conn_sis)
  {
//     return "Coneccion exitosa";
  }
  else
  {
      die(print_r(sqlsrv_errors(), true));
  }

  $output="";
  $sql = "{call wfsp_generalQuery(?,?)}";
  $params = array
  (
  array($param1,SQLSRV_PARAM_IN),
  array(&$output, SQLSRV_PARAM_INOUT)
  );

  $stmt = sqlsrv_query($conn_sis, $sql, $params);


  if( $stmt === false )
  {
//   echo "Error in executing statement 3.\n";
  die( print_r( sqlsrv_errors(), true));
  }

//  sqlsrv_next_result($stmt);
  sqlsrv_free_stmt($stmt);
  sqlsrv_close($conn_sis);
  return $output;
}

// Function to edit a deduction
function editDeduction($param1, $param2)
{
    $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
    $conectionInfo = array("Database"=>"WorkerForm", "UID"=>"user", "PWD"=>"password", "CharacterSet"=>"UTF-8");
    $conn_sis = sqlsrv_connect($servername, $conectionInfo);

    if($conn_sis)
    {
//     return "Coneccion exitosa";
    }
    else
    {
        die(print_r(sqlsrv_errors(), true));
    }

    $output="";
    $sql = "{call wfsp_generalQuery(?,?)}";
    $params = array
    (
        array($param1,SQLSRV_PARAM_IN),
        array($param2,SQLSRV_PARAM_IN),
        array(&$output, SQLSRV_PARAM_INOUT)
    );

    $stmt = sqlsrv_query($conn_sis, $sql, $params);


    if( $stmt === false )
    {
//   echo "Error in executing statement 3.\n";
        die( print_r( sqlsrv_errors(), true));
    }

//  sqlsrv_next_result($stmt);
    sqlsrv_free_stmt($stmt);
    sqlsrv_close($conn_sis);
    return $output;
}

// Function to edit a bonus
function editBonus($param1, $param2)
{
    $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
    $conectionInfo = array("Database"=>"WorkerForm", "UID"=>"user", "PWD"=>"password", "CharacterSet"=>"UTF-8");
    $conn_sis = sqlsrv_connect($servername, $conectionInfo);

    if($conn_sis)
    {
//     return "Coneccion exitosa";
    }
    else
    {
        die(print_r(sqlsrv_errors(), true));
    }

    $output="";
    $sql = "{call wfsp_generalQuery(?,?)}";
    $params = array
    (
        array($param1,SQLSRV_PARAM_IN),
        array($param2,SQLSRV_PARAM_IN),
        array(&$output, SQLSRV_PARAM_INOUT)
    );

    $stmt = sqlsrv_query($conn_sis, $sql, $params);


    if( $stmt === false )
    {
//   echo "Error in executing statement 3.\n";
        die( print_r( sqlsrv_errors(), true));
    }

//  sqlsrv_next_result($stmt);
    sqlsrv_free_stmt($stmt);
    sqlsrv_close($conn_sis);
    return $output;
}

// Function to edit the employee value per hour
function editValue($param1, $param2)
{
    $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
    $conectionInfo = array("Database"=>"WorkerForm", "UID"=>"user", "PWD"=>"password", "CharacterSet"=>"UTF-8");
    $conn_sis = sqlsrv_connect($servername, $conectionInfo);

    if($conn_sis)
    {
//     return "Coneccion exitosa";
    }
    else
    {
        die(print_r(sqlsrv_errors(), true));
    }

    $output="";
    $sql = "{call wfsp_generalQuery(?,?)}";
    $params = array
    (
        array($param1,SQLSRV_PARAM_IN),
        array($param2,SQLSRV_PARAM_IN),
        array(&$output, SQLSRV_PARAM_INOUT)
    );

    $stmt = sqlsrv_query($conn_sis, $sql, $params);


    if( $stmt === false )
    {
//   echo "Error in executing statement 3.\n";
        die( print_r( sqlsrv_errors(), true));
    }

//  sqlsrv_next_result($stmt);
    sqlsrv_free_stmt($stmt);
    sqlsrv_close($conn_sis);
    return $output;
}


// Funcion para consultar clientes en la base de datos.
function consultarUsuario($param1)
{
  $servername = 'DESKTOP-LFI86EI\SQLEXPRESS';
  $conectionInfo = array("Database"=>"WorkerForm", "UID"=>"user", "PWD"=>"password", "CharacterSet"=>"UTF-8");
  $conn_sis = sqlsrv_connect($servername, $conectionInfo);

  if($conn_sis)
  {
    // echo "Conexion exitosa";
  }
  else
  {
      die(print_r(sqlsrv_errors(), true));
  }

  $outSeq=0;
  $sql = "{call wfsp_login(?,?)}";
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

?>
