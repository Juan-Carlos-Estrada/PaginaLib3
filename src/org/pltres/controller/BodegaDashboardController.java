/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/javafx/FXMLController.java to edit this template
 */
package org.pltres.controller;

import java.net.URL;
import java.util.ResourceBundle;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Button;
import javafx.scene.control.Label;

public class BodegaDashboardController implements Initializable {

    @FXML
    private Label lblUsuario;
    @FXML
    private Button btnCerrarSesion;
    @FXML
    private Button btnNavLibros;
    @FXML
    private Button btnNavIngreso;
    @FXML
    private Button btnNavSalida;
    @FXML
    private Button btnNavMovimientos;

    /**
     * Initializes the controller class.
     */
    @Override
    public void initialize(URL url, ResourceBundle rb) {
        // TODO
    }    
    
}
