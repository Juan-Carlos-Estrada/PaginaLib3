package org.pltres.dao;

import org.pltres.model.Usuario;

public interface UsuarioDAO extends CRUD <Usuario,Integer>{
    Usuario iniciarSesion(String username, String passworHash);
    boolean registrarUsuario(String username, String password, String rol);
    Usuario validarCredenciales(String usename, String passwordHash);
    boolean actualiuzarPassword(String username, String nuevoPasswordHash);
    Usuario buscarPorUsername(String username);
}   