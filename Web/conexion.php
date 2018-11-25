<?php

if(isset($_POST['hidden']))
{
    echo consultarValues();
}

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
    echo estados($valorDocId);
}

// Consult workers forms
if((isset($_POST["idemployeeJob"])) and $_POST["idemployeeJob"] != "")
{
    $valorDocId = $_POST['idemployeeJob'];
    echo workerForms($valorDocId);
}

// Edit deduction
if((isset($_POST["idEmployeeDeduction"])) and $_POST["idEmployeeDeduction"] != "" and (isset($_POST["deductionAmount"])) and $_POST["deductionAmount"] != ""
    and (isset($_POST["idDeduction"])) and $_POST["idDeduction"] != "")
{
    // Editar deducción
    $idBonus = $_POST['idBonus'];
    $bonusAmount = $_POST['bonusAmount'];
    $idEmployeeAmount = $_POST['idEmployeeBonus'];
    echo editDeduction($idEmployeeAmount, $idBonus, $bonusAmount);
}


// ediat bonus
if((isset($_POST["idBonus"])) and $_POST["idBonus"] != "" and (isset($_POST["bonusAmount"])) and $_POST["bonusAmount"] != ""
    and (isset($_POST["idEmployeeBonus"])) and $_POST["idEmployeeBonus"] != "")
{
    // Editar deducción
    $idBonus = $_POST['idBonus'];
    $bonusAmount = $_POST['bonusAmount'];
    $idEmployeeAmount = $_POST['idEmployeeBonus'];
    echo editBonus($idEmployeeAmount, $idBonus, $bonusAmount);
}

// edit el valor por hora de un empleado
if((isset($_POST["idEmployeeValue"])) and $_POST["idEmployeeValue"] != "" and (isset($_POST["valueEmployee"])) and $_POST["valueEmployee"] != "")
{
    // Editar deducción
    $idEmployeeValue = $_POST['idEmployeeValue'];
    $valueEmployee = $_POST['valueEmployee'];
    echo editValue($idEmployeeValue, $valueEmployee);
//    echo estados($userId);
}



// Funcion para consultar clientes en la base de datos.
function consultarValues()
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

    $outSeq="";
    $sql = "{call wfsp_valuesQuery(?)}";
    $params = array
    (
        array(&$outSeq, SQLSRV_PARAM_INOUT)
    );

    $stmt = sqlsrv_query($conn_sis, $sql, $params) or die(print_r(sqlsrv_errors(),true));

    if( $stmt === false )
    {
        // echo "Error in executing statement 3.\n";
        die( print_r( sqlsrv_errors(), true));
    }

    sqlsrv_next_result($stmt);
    sqlsrv_next_result($stmt);
    sqlsrv_close($conn_sis);
    return $outSeq;

}

// Funcion para consultar todas las planillas de un empleado
function workerForms($param1)
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
    $sql = "{call wfsp_employeeFormsQuery(?,?)}";
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

    sqlsrv_next_result($stmt);
    sqlsrv_free_stmt($stmt);
    sqlsrv_close($conn_sis);
    return $output;
}

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

  sqlsrv_next_result($stmt);
  sqlsrv_free_stmt($stmt);
  sqlsrv_close($conn_sis);
  return $output;
}

// Function to edit a deduction
function editDeduction($param1, $param2, $param3)
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

    $output=0;
    $sql = "{call wfsp_editDeduction(?,?,?,?)}";
    $params = array
    (
        array($param1,SQLSRV_PARAM_IN),
        array($param2,SQLSRV_PARAM_IN),
        array($param3,SQLSRV_PARAM_IN),
        array(&$output, SQLSRV_PARAM_INOUT)
    );

    $stmt = sqlsrv_query($conn_sis, $sql, $params);


    if( $stmt === false )
    {
//   echo "Error in executing statement 3.\n";
        die( print_r( sqlsrv_errors(), true));
    }

    sqlsrv_next_result($stmt);
    sqlsrv_free_stmt($stmt);
    sqlsrv_close($conn_sis);
    return $output;
}

// Function to edit a bonus
function editBonus($param1, $param2, $param3)
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

    $output=-1;
    $sql = "{call wfsp_editBonus(?,?,?,?)}";
    $params = array
    (
        array($param1,SQLSRV_PARAM_IN),
        array($param2,SQLSRV_PARAM_IN),
        array($param3,SQLSRV_PARAM_IN),
        array(&$output, SQLSRV_PARAM_INOUT)
    );

    $stmt = sqlsrv_query($conn_sis, $sql, $params);


    if( $stmt === false )
    {
//   echo "Error in executing statement 3.\n";
        die( print_r( sqlsrv_errors(), true));
    }

    sqlsrv_next_result($stmt);
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

    $output=0;
    $sql = "{call wfsp_editValue(?,?,?)}";
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

    sqlsrv_next_result($stmt);
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
    sqlsrv_free_stmt($stmt);
  sqlsrv_close($conn_sis);
  return $outSeq;

}

?>
