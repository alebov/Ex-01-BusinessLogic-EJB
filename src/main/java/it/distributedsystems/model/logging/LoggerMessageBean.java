package it.distributedsystems.model.logging;

import org.apache.log4j.Logger;

import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.TextMessage;

@MessageDriven(activationConfig =  {
        @ActivationConfigProperty(
                propertyName = "destinationType",
                propertyValue = "javax.jms.Queue"),
        @ActivationConfigProperty(
                propertyName = "destination",
                propertyValue = "jms/queue/interceptions")
})
public class LoggerMessageBean implements MessageListener {
    private static Logger logger = Logger.getLogger("MDBean");

    @Override
    public void onMessage(Message message) {
        try {
            if(message instanceof TextMessage) {
                logger.info(((TextMessage) message).getText());
            } else {
                logger.warn("Received wrong message format");
            }
        } catch (JMSException e) {
            e.printStackTrace();
        }
    }
}
