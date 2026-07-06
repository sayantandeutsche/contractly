package com.crm.converter;

import org.hibernate.engine.spi.SharedSessionContractImplementor;
import org.hibernate.usertype.UserType;
import java.io.*;
import java.sql.*;

/**
 * Custom Hibernate UserType that writes String values to Postgres
 * enum columns by using setObject with the OTHER JDBC type code.
 * This forces Postgres to receive the value as an untyped object
 * and perform its own implicit cast from text to the enum type.
 *
 * Usage on entity field:
 *   @Type(PostgresEnumType.class)
 *   private String myEnumField;
 *
 * No need to specify the enum type name — Postgres infers it from
 * the column definition.
 */
public class PostgresEnumType implements UserType<String> {

    @Override
    public int getSqlType() {
        return Types.OTHER;
    }

    @Override
    public Class<String> returnedClass() {
        return String.class;
    }

    @Override
    public boolean equals(String x, String y) {
        if (x == null) return y == null;
        return x.equals(y);
    }

    @Override
    public int hashCode(String x) {
        return x == null ? 0 : x.hashCode();
    }

    @Override
    public String nullSafeGet(ResultSet rs, int position,
                              SharedSessionContractImplementor session,
                              Object owner) throws SQLException {
        return rs.getString(position);
    }

    @Override
    public void nullSafeSet(PreparedStatement st, String value, int index,
                            SharedSessionContractImplementor session) throws SQLException {
        if (value == null) {
            st.setNull(index, Types.OTHER);
        } else {
            st.setObject(index, value, Types.OTHER);
        }
    }

    @Override
    public String deepCopy(String value) { return value; }

    @Override
    public boolean isMutable() { return false; }

    @Override
    public Serializable disassemble(String value) { return value; }

    @Override
    public String assemble(Serializable cached, Object owner) { return (String) cached; }
}
