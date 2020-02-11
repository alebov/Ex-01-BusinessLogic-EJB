package it.distributedsystems.model.logging;

import javax.interceptor.AroundInvoke;
import javax.interceptor.InvocationContext;

public class OperationLogger {

    @AroundInvoke
    public Object intercept(InvocationContext ctx) throws Exception{
        String methodName = ctx.getMethod().getName();
        Object result = null;
        if(methodName.equals("insertCustomer")){
            System.out.println("[LOG] -- Richiesta di inserimento di un customer nel database");
            result = ctx.proceed();
            System.out.println("[LOG] -- Customer inserito");
        }
        else if(methodName.equals("insertProducer")){
            System.out.println("[LOG] -- Richiesta di inserimento di un produttore nel database");
            result = ctx.proceed();
            System.out.println("[LOG] -- Produttore inserito");
        }
        else if(methodName.equals("insertProduct")){
            System.out.println("[LOG] -- Richiesta di inserimento di un prodotto nel database");
            result = ctx.proceed();
            System.out.println("[LOG] -- Prodotto inserito");
        }
        else if(methodName.equals("insertPurchase")){
            System.out.println("[LOG] -- Richiesta di inserimento di un acquisto nel database");
            result = ctx.proceed();
            System.out.println("[LOG] -- Acquisto inserito");
        }

        return result;
    }
}
