use libreriadb_in4cm;

-- libros
alter table libros
add column stock_actual int not null default 0,
add column stock_minimo int not null default 0,
add column activo boolean not null default true;

-- proveedores
create table proveedores(
	id_proveedor int primary key auto_increment,
    nombre_proveedor varchar(100) not null,
    telefono_proveedor varchar(15),
    direccion_proveedor varchar(100)
);

-- usuarios
create table usuarios(
	id int primary key auto_increment,
    username varchar(50) not null unique,
    password_hash varchar(255) not null,
    rol enum('admin','bodega','cajero') not null,
    activo boolean not null default true,
    fecha_creacion timestamp default current_timestamp
);

-- movimientos_inventario
create table movimientos_inventario(
	id_movimiento int primary key auto_increment,
    isbn varchar(20),
    tipo_movimiento enum('INGRESO','VENTA','MERMA','TRASLADO','DEVOLUCION','AJUSTE') not null,
    cantidad int not null,
    fecha_movimiento timestamp default current_timestamp,
    id_usuario int,
    id_proveedor int,
    observacion varchar(255)
);

-- llaves foraneas
alter table movimientos_inventario
add constraint fk_mov_libro foreign key (isbn) references libros(isbn) on delete cascade,
add constraint fk_mov_usuario foreign key (id_usuario) references usuarios(id) on delete cascade,
add constraint fk_mov_proveedor foreign key (id_proveedor) references proveedores(id_proveedor) on delete set null;

use libreriadb_in4cm;

-- crud: proveedores
delimiter $$

create procedure sp_insertarproveedor(
    in _nombre_proveedor varchar(100),
    in _telefono_proveedor varchar(15),
    in _direccion_proveedor varchar(100)
)
begin
    insert into proveedores(nombre_proveedor, telefono_proveedor, direccion_proveedor)
    values (_nombre_proveedor, _telefono_proveedor, _direccion_proveedor);
end $$

create procedure sp_listarproveedores()
begin
    select id_proveedor, nombre_proveedor, telefono_proveedor, direccion_proveedor from proveedores;
end $$

create procedure sp_buscarproveedor(
    in _id_proveedor int
)
begin
    select id_proveedor, nombre_proveedor, telefono_proveedor, direccion_proveedor
    from proveedores
    where id_proveedor = _id_proveedor;
end $$

create procedure sp_actualizarproveedor(
    in _id_proveedor int,
    in _nombre_proveedor varchar(100),
    in _telefono_proveedor varchar(15),
    in _direccion_proveedor varchar(100)
)
begin
    update proveedores
    set nombre_proveedor = _nombre_proveedor,
        telefono_proveedor = _telefono_proveedor,
        direccion_proveedor = _direccion_proveedor
    where id_proveedor = _id_proveedor;
end $$

create procedure sp_eliminarproveedor(
    in _id_proveedor int
)
begin
    delete from proveedores where id_proveedor = _id_proveedor;
end $$

delimiter ;

-- crud: usuarios
delimiter $$

create procedure sp_insertarusuario(
    in _username varchar(50),
    in _password_hash varchar(255),
    in _rol enum('admin','bodega','cajero')
)
begin
    insert into usuarios(username, password_hash, rol)
    values (_username, _password_hash, _rol);
end $$

create procedure sp_listarusuarios()
begin
    select id, username, rol, activo, fecha_creacion from usuarios;
end $$

create procedure sp_buscarusuario(
    in _id int
)
begin
    select id, username, rol, activo, fecha_creacion
    from usuarios
    where id = _id;
end $$

create procedure sp_autenticarusuario(
    in _username varchar(50)
)
begin
    select id, username, password_hash, rol, activo
    from usuarios
    where username = _username;
end $$

create procedure sp_actualizarusuario(
    in _id int,
    in _rol enum('admin','bodega','cajero')
)
begin
    update usuarios
    set rol = _rol
    where id = _id;
end $$

create procedure sp_eliminarusuario(
    in _id int
)
begin
    delete from usuarios where id = _id;
end $$

delimiter ;

-- crud: movimientos_inventario
delimiter $$

create procedure sp_insertarmovimientoinventario(
    in _isbn varchar(20),
    in _tipo_movimiento enum('INGRESO','VENTA','MERMA','TRASLADO','DEVOLUCION','AJUSTE'),
    in _cantidad int,
    in _id_usuario int,
    in _id_proveedor int,
    in _observacion varchar(255)
)
begin
    insert into movimientos_inventario(isbn, tipo_movimiento, cantidad, id_usuario, id_proveedor, observacion)
    values (_isbn, _tipo_movimiento, _cantidad, _id_usuario, _id_proveedor, _observacion);
end $$

create procedure sp_listarmovimientosinventario()
begin
    select id_movimiento, isbn, tipo_movimiento, cantidad, fecha_movimiento, id_usuario, id_proveedor, observacion
    from movimientos_inventario;
end $$

create procedure sp_buscarmovimientoinventario(
    in _id_movimiento int
)
begin
    select id_movimiento, isbn, tipo_movimiento, cantidad, fecha_movimiento, id_usuario, id_proveedor, observacion
    from movimientos_inventario
    where id_movimiento = _id_movimiento;
end $$

create procedure sp_eliminarmovimientoinventario(
    in _id_movimiento int
)
begin
    delete from movimientos_inventario where id_movimiento = _id_movimiento;
end $$

delimiter ;

-- crud: control de stock en libros
delimiter $$

create procedure sp_listarlibroscritico()
begin
    select isbn, titulo, stock_actual, stock_minimo
    from libros
    where stock_actual <= stock_minimo and activo = true;
end $$

create procedure sp_registraringreso(
    in _isbn varchar(20),
    in _cantidad int,
    in _id_usuario int,
    in _id_proveedor int,
    in _observacion varchar(255)
)
begin
    update libros set stock_actual = stock_actual + _cantidad where isbn = _isbn;
    insert into movimientos_inventario(isbn, tipo_movimiento, cantidad, id_usuario, id_proveedor, observacion)
    values (_isbn, 'INGRESO', _cantidad, _id_usuario, _id_proveedor, _observacion);
end $$

create procedure sp_registrarsalida(
    in _isbn varchar(20),
    in _tipo_movimiento enum('INGRESO','VENTA','MERMA','TRASLADO','DEVOLUCION','AJUSTE'),
    in _cantidad int,
    in _id_usuario int,
    in _observacion varchar(255)
)
begin
    update libros set stock_actual = stock_actual - _cantidad where isbn = _isbn;
    insert into movimientos_inventario(isbn, tipo_movimiento, cantidad, id_usuario, observacion)
    values (_isbn, _tipo_movimiento, _cantidad, _id_usuario, _observacion);
end $$

delimiter ;

use libreriadb_in4cm;

-- vistas
create or replace view vw_libros_stock_critico as
select
    isbn as 'isbn',
    titulo as 'título',
    stock_actual as 'stock actual',
    stock_minimo as 'stock mínimo'
from libros
where stock_actual <= stock_minimo and activo = true;

create or replace view vw_lista_usuarios as
select
    id as 'id usuario',
    username as 'usuario',
    rol as 'rol',
    activo as 'activo'
from usuarios;

create or replace view vw_lista_proveedores as
select
    id_proveedor as 'id proveedor',
    nombre_proveedor as 'proveedor',
    telefono_proveedor as 'teléfono',
    direccion_proveedor as 'dirección'
from proveedores;

create or replace view vw_lista_movimientos_inventario as
select
    m.id_movimiento as 'id movimiento',
    l.titulo as 'libro',
    m.tipo_movimiento as 'tipo',
    m.cantidad as 'cantidad',
    m.fecha_movimiento as 'fecha',
    p.nombre_proveedor as 'proveedor'
from movimientos_inventario m
inner join libros l on m.isbn = l.isbn
left join proveedores p on m.id_proveedor = p.id_proveedor;

-- poblado
CALL sp_insertarproveedor('Distribuidora Maya S.A.', '22110011', 'Zona 4, Ciudad');
CALL sp_insertarproveedor('Libros y Más Guatemala', '22110022', 'Zona 9, Ciudad');
CALL sp_insertarproveedor('Importadora Editorial Centroamérica', '22110033', 'Zona 12, Ciudad');

CALL sp_insertarusuario('admin', 'HASH_ADMIN_EJEMPLO', 'admin');
CALL sp_insertarusuario('bodega1', 'HASH_BODEGA_EJEMPLO', 'bodega');
CALL sp_insertarusuario('cajero1', 'HASH_CAJERO_EJEMPLO', 'cajero');

CALL sp_registraringreso('978-0-123', 20, 2, 1, 'stock inicial');
CALL sp_registraringreso('978-0-124', 15, 2, 2, 'stock inicial');
CALL sp_registraringreso('978-0-125', 8, 2, 3, 'stock inicial');
CALL sp_registraringreso('978-0-126', 25, 2, 1, 'stock inicial');
CALL sp_registraringreso('978-0-127', 3, 2, 2, 'stock inicial');
CALL sp_registraringreso('978-0-128', 12, 2, 3, 'stock inicial');
CALL sp_registraringreso('978-0-129', 18, 2, 1, 'stock inicial');
CALL sp_registraringreso('978-0-130', 10, 2, 2, 'stock inicial');
CALL sp_registraringreso('978-0-131', 2, 2, 3, 'stock inicial');
CALL sp_registraringreso('978-0-132', 14, 2, 1, 'stock inicial');
CALL sp_registraringreso('978-0-133', 9, 2, 2, 'stock inicial');
CALL sp_registraringreso('978-0-134', 6, 2, 3, 'stock inicial');

CALL sp_registrarsalida('978-0-131', 'MERMA', 1, 2, 'libro dañado en bodega');

select * from vw_libros_stock_critico;
select * from vw_lista_movimientos_inventario;
