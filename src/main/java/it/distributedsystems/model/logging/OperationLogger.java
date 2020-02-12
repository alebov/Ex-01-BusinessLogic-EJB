package it.distributedsystems.model.logging;

import org.apache.log4j.Logger;

import javax.interceptor.AroundInvoke;
import javax.interceptor.InvocationContext;
import javax.jms.*;
import javax.naming.InitialContext;

public class OperationLogger {

    private static Logger logger = Logger.getLogger("OperationLogger");

    @AroundInvoke
    public Object intercept(InvocationContext ctx) throws Exception{
        String methodName = ctx.getMethod().getName();
        logger.info("Intercepted method: " + methodName);

        QueueConnectionFactory qcf = getQueueConnectionFactory();
        Queue queue = getQueue();
        try {
            QueueConnection queueConnection = qcf.createQueueConnection();
            if(queueConnection != null)
                logger.info("QueueConnection created");
            else
                logger.warn("QueueConnection is null");
            QueueSession session = queueConnection.createQueueSession(false, QueueSession.AUTO_ACKNOWLEDGE);
            if(session != null)
                logger.info("QueueSession created");
            else
                logger.warn("QueueSession is null");
            QueueSender sender = session.createSender(queue);
            if(sender != null)
                logger.info("QueueSender created");
            else
                logger.warn("QueueSender is null");
            queueConnection.start();
            logger.info("QueueConnection started");
            TextMessage message = session.createTextMessage();
            message.setText("Intercepted method: " + methodName);
            sender.send(message);
            logger.info("Message sent");
            queueConnection.close();
        } catch (Exception e){
            logger.error(e);
            return null;
        }
        return ctx.proceed();
    }

    private Queue getQueue() {
        try {
            InitialContext context = new InitialContext();
            Queue queue = (Queue) context.lookup("jms/queue/interceptions");
            if(queue != null) {
                logger.info("Queue looked up");
                return queue;
            } else{
                logger.warn("After looking it up Queue is null");
                return null;
            }
        } catch (Exception e){
            logger.error("Error looking up the Queue", e);
            return null;
        }
    }

    private QueueConnectionFactory getQueueConnectionFactory() {
        try {
            InitialContext context = new InitialContext();
            QueueConnectionFactory factory = (QueueConnectionFactory) context.lookup("java:/ConnectionFactory");
            if(factory != null) {
                logger.info("QueueConnectionFactory looked up");
                return factory;
            } else {
                logger.warn("After looking it up QueueConnectionFactory is null");
                return null;
            }
        } catch (Exception e){
            logger.error("Error looking up the Connection Factory", e);
            return null;
        }
    }


}
