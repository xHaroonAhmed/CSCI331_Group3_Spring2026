package eos_grp_3.interfaces;

import java.util.List;

/**
 * EOS_GRP_3_Class_Library
 * Generic CRUD repository interface — implement for each entity.
 */
public interface IDataRepository<T> {
    List<T> getAll() throws Exception;
    T getById(int id) throws Exception;
    int insert(T entity) throws Exception;
    int update(T entity) throws Exception;
    int delete(int id) throws Exception;
}