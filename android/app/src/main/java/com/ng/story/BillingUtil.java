package com.ng.story;

import android.app.Activity;

import androidx.annotation.Nullable;

import com.android.billingclient.api.AcknowledgePurchaseParams;
import com.android.billingclient.api.AcknowledgePurchaseResponseListener;
import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.ConsumeParams;
import com.android.billingclient.api.ConsumeResponseListener;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.android.billingclient.api.SkuDetails;
import com.android.billingclient.api.SkuDetailsParams;
import com.android.billingclient.api.SkuDetailsResponseListener;


import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class BillingUtil implements PurchasesUpdatedListener {

    private static BillingClient mBillingClient;

    private boolean mIsServiceConnected;

    private final List<Purchase> mPurchases = new ArrayList<>();

    // Default value of mBillingClientResponseCode until BillingManager was not yeat initialized
//    public static final int BILLING_MANAGER_NOT_INITIALIZED  = -1;
//    private  int mBillingClientResponseCode =BILLING_MANAGER_NOT_INITIALIZED;

    private BillingUpdatesListener mBillingUpdatesListener;
    private Activity mActivity;

    private Set<String> mTokensToBeConsumed;
    private static BillingUtil mSingleton = null;
    private BillingUtil() {}

    /**
     * 鑾峰彇瀹炰緥瀵硅薄
     *
     * @return
     */
    public static BillingUtil getInstance() {
        if (mSingleton == null) {
            synchronized (BillingUtil.class) {
                if (mSingleton == null) {
                    mSingleton = new BillingUtil();
                }
            }
        }
        return mSingleton;
    }

    /**
     * 鍒濆鍖栬繛鎺ワ紝寰楀埌杩炴帴
     * @param activity
     * @param updatesListener
     */
    public void clientConnection(Activity activity, BillingUpdatesListener updatesListener) {
        if (mBillingClient == null) {
            mBillingClient = BillingClient.newBuilder(activity).setListener(this).enablePendingPurchases().build();
        }
        this.mActivity=activity;
        mBillingUpdatesListener=updatesListener;
        startServiceConnection(new Runnable() {
            @Override
            public void run() {
                mBillingUpdatesListener.onBillingClientSetupFinished();
                queryPurchases();
            }
        });

    }

    /**
    
     * @param executeOnSuccess
     */
    private void startServiceConnection(final Runnable executeOnSuccess) {
        mBillingClient.startConnection(new BillingClientStateListener() {
            @Override
            public void onBillingSetupFinished(BillingResult billingResult) {
              
                if(billingResult.getResponseCode()== BillingClient.BillingResponseCode.OK){
    
                    mIsServiceConnected=true;
                    executeOnSuccess.run();

                }else {

                    Bridge.d(billingResult.getDebugMessage()+billingResult.getResponseCode());
                    if (mBillingUpdatesListener !=  null){
                        mBillingUpdatesListener.onVersionNotSupport();
                    }

                }
                int responseCode=billingResult.getResponseCode();
//                mBillingClientResponseCode=responseCode;

            }

            @Override
            public void onBillingServiceDisconnected() {
                mIsServiceConnected = false;
            }
        });

    }


    @Override
    public void onPurchasesUpdated(BillingResult billingResult, @Nullable List<Purchase> purchases) {
        if(billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK){
            for (Purchase purchase : purchases) {
//                handlePurchase(purchase);
                /**
                 * 杩欓噷寤鸿杩涜鍚庡彴鎿嶄綔
                 */

            }
            mBillingUpdatesListener.onPurchasesUpdated(purchases);
        }else{
            mBillingUpdatesListener.onPurchasesCancelled(billingResult.getResponseCode());
            Bridge.d("onPurchasesUpdated() - user cancelled the purchase flow - skipping");
        }
    }

    /**
    
     * a listener
     */
    public void queryPurchases() {
        Runnable queryToExecute = new Runnable() {
            @Override
            public void run() {
                long time = System.currentTimeMillis();
                Purchase.PurchasesResult purchasesResult = mBillingClient.queryPurchases(BillingClient.SkuType.INAPP);
                Bridge.d("Querying purchases elapsed time: " + (System.currentTimeMillis() - time)
                        + "ms");
                // If there are subscriptions supported, we add subscription rows as well
                if (areSubscriptionsSupported()) {
                    Purchase.PurchasesResult subscriptionResult
                            = mBillingClient.queryPurchases(BillingClient.SkuType.SUBS);
                    Bridge.d("Querying purchases and subscriptions elapsed time: "
                            + (System.currentTimeMillis() - time) + "ms");
                    Bridge.d( "Querying subscriptions result code: "
                            + subscriptionResult.getResponseCode()
                            + " res: " + subscriptionResult.getPurchasesList().size());

                    if (subscriptionResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                        purchasesResult.getPurchasesList().addAll(
                                subscriptionResult.getPurchasesList());
                    } else {
                        Bridge.d("Got an error response trying to query subscription purchases");
                    }
                } else if (purchasesResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
                    Bridge.d( "Skipped subscription purchases query since they are not supported");
                } else {
                    Bridge.d( "queryPurchases() got an error response code: "
                            + purchasesResult.getResponseCode());
                }
                onQueryPurchasesFinished(purchasesResult);
            }
        };

        executeServiceRequest(queryToExecute);
    }

    /**
    
     * @param runnable
     */
    private void executeServiceRequest(Runnable runnable) {
        if (mIsServiceConnected) {
            runnable.run();
        } else {
            // If billing service was disconnected, we try to reconnect 1 time.
            // (feel free to introduce your retry policy here).
            startServiceConnection(runnable);
        }
    }

    /**
     * Listener to the updates that happen when purchases list was updated or consumption of the
     * item was finished
     * 澶栭儴璋冪敤鎺ュ彛
     */
    public interface BillingUpdatesListener {
        void onBillingClientSetupFinished();
        void onBillingClientSetupFinishedFailed();
        //        void onConsumeFinished(String token, @BillingResponse int result);
        void onConsumeFinished(String token, @BillingClient.BillingResponseCode int result);

        void onPurchasesUpdated(List<Purchase> purchases);

        void onPurchasesCancelled(@BillingClient.BillingResponseCode int responseCode);

      
        void onVersionNotSupport();

    }

    /**
     *
  
     * Checks if subscriptions are supported for current client
     * <p>Note: This method does not automatically retry for RESULT_SERVICE_DISCONNECTED.
     * It is only used in unit tests and after queryPurchases execution, which already has
     * a retry-mechanism implemented.
     * </p>
     */
    public boolean areSubscriptionsSupported() {
        BillingResult billingResult= mBillingClient.isFeatureSupported(BillingClient.FeatureType.SUBSCRIPTIONS);

        if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
            Bridge.d("areSubscriptionsSupported() got an error response: " + billingResult.getResponseCode());
        }
        return billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK;
    }


    /**
   
     * Handle a result from querying of purchases and report an updated list to the listener
     */
    private void onQueryPurchasesFinished(Purchase.PurchasesResult result) {
        // Have we been disposed of in the meantime? If so, or bad result code, then quit
        if (mBillingClient == null || result.getResponseCode() != BillingClient.BillingResponseCode.OK) {
            Bridge.d("Billing client was null or result code (" + result.getResponseCode()
                    + ") was bad - quitting");
            return;
        }

        Bridge.d( "Query inventory was successful.");

        // Update the UI and purchases inventory with new list of purchases
        mPurchases.clear();
        BillingResult billingResult= BillingResult.newBuilder().setResponseCode(BillingClient.BillingResponseCode.OK).build();

        onPurchasesUpdated(billingResult, result.getPurchasesList());
    }

    /**
     
     * Clear the resources
     */
    public void destroy() {
        Bridge.d( "Destroying the manager.");
        if(mTokensToBeConsumed!=null){
            mTokensToBeConsumed.clear();
        }
        if (mBillingClient != null && mBillingClient.isReady()) {
            mBillingClient.endConnection();
            mBillingClient = null;
        }
    }


    /**
    
     * Start a purchase flow
     */
    public void initiatePurchaseFlow(final SkuDetails skuDetails, final @BillingClient.SkuType String billingType) {
        initiatePurchaseFlow(mActivity,skuDetails, null, billingType);
    }

    /**
     * Start a purchase or subscription replace flow
     */
    public void initiatePurchaseFlow(Activity mActivitys, final SkuDetails skuDetails, final ArrayList<String> oldSkus,
                                     final @BillingClient.SkuType String billingType) {
        Runnable purchaseFlowRequest = new Runnable() {
            @Override
            public void run() {
                Bridge.d( "Launching in-app purchase flow. Replace old SKU? " + (oldSkus));
//                querySkuDetailsAsync();
                BillingFlowParams purchaseParams = BillingFlowParams.newBuilder().setSkuDetails(skuDetails)
                 .build();
                        // .setOldSkus(oldSkus)
                       
                mBillingClient.launchBillingFlow(mActivitys, purchaseParams);
            }
        };

        executeServiceRequest(purchaseFlowRequest);
    }


    /**
    
     * @param itemType
     * @param skuList
     * @param listener
     */

    public void querySkuDetailsAsync(@BillingClient.SkuType final String itemType, final List<String> skuList,
                                     final SkuDetailsResponseListener listener) {
        // Creating a runnable from the request to use it inside our connection retry policy below
        Runnable queryRequest = new Runnable() {
            @Override
            public void run() {
                // Query the purchase async
                SkuDetailsParams.Builder params = SkuDetailsParams.newBuilder();
                params.setSkusList(skuList).setType(itemType);
                mBillingClient.querySkuDetailsAsync(params.build(), new SkuDetailsResponseListener() {
                    @Override
                    public void onSkuDetailsResponse(BillingResult billingResult, List<SkuDetails> skuDetailsList) {
                        listener.onSkuDetailsResponse(billingResult, skuDetailsList);
                    }
                });
//                new SkuDetailsResponseListener() {
//                            @Override
//                            public void onSkuDetailsResponse(int responseCode,
//                                                             List<SkuDetails> skuDetailsList) {
//                                listener.onSkuDetailsResponse(responseCode, skuDetailsList);
//                            }
//                        });
            }
        };

        executeServiceRequest(queryRequest);
    }


    /**
   
     * @param consumeAsync
     */

    public void consumeAsync(final ConsumeParams consumeAsync) {
        // If we've already scheduled to consume this token - no action is needed (this could happen
        // if you received the token when querying purchases inside onReceive() and later from
        // onActivityResult()
        if (mTokensToBeConsumed == null) {
            mTokensToBeConsumed = new HashSet<>();
        }
        else if (mTokensToBeConsumed.contains(consumeAsync.getPurchaseToken())) {
            Bridge.d( "Token was already scheduled to be consumed - skipping...");
            return;
        }
        mTokensToBeConsumed.add(consumeAsync.getPurchaseToken());
        // Generating Consume Response listener
        final ConsumeResponseListener onConsumeListener = new ConsumeResponseListener() {
            @Override
            public void onConsumeResponse(BillingResult billingResult, String purchaseToken) {
                mBillingUpdatesListener.onConsumeFinished(purchaseToken, billingResult.getResponseCode());
            }
        };

        // Creating a runnable from the request to use it inside our connection retry policy below
        Runnable consumeRequest = new Runnable() {
            @Override
            public void run() {
                // Consume the purchase async
                mBillingClient.consumeAsync(consumeAsync, onConsumeListener);
//                mBillingClient.consumeAsync(, onConsumeListener);
            }
        };

        executeServiceRequest(consumeRequest);
    }

    /**
    
     * @param acknowledgePurchaseParams
     */

    public void consumeAsyncs(final AcknowledgePurchaseParams acknowledgePurchaseParams) {
        // If we've already scheduled to consume this token - no action is needed (this could happen
        // if you received the token when querying purchases inside onReceive() and later from
        // onActivityResult()
        if (mTokensToBeConsumed == null) {
            mTokensToBeConsumed = new HashSet<>();
        }
        else if (mTokensToBeConsumed.contains(acknowledgePurchaseParams.getPurchaseToken())) {
            Bridge.d( "Token was already scheduled to be consumed - skipping...");
            return;
        }
        mTokensToBeConsumed.add(acknowledgePurchaseParams.getPurchaseToken());
        // Generating Consume Response listener
        final AcknowledgePurchaseResponseListener onConsumeListener = new AcknowledgePurchaseResponseListener() {
            @Override
            public void onAcknowledgePurchaseResponse(BillingResult billingResult) {
                mBillingUpdatesListener.onConsumeFinished(acknowledgePurchaseParams.getPurchaseToken(), billingResult.getResponseCode());
            }
        };

        // Creating a runnable from the request to use it inside our connection retry policy below
        Runnable consumeRequest = new Runnable() {
            @Override
            public void run() {
                // Consume the purchase async
                mBillingClient.acknowledgePurchase(acknowledgePurchaseParams,onConsumeListener);
//                mBillingClient.consumeAsync(, onConsumeListener);
            }
        };

        executeServiceRequest(consumeRequest);
    }

//    /**
//     *
//     * @param purchase
//     */
//    private void handlePurchase(Purchase purchase)  {
//        if (!verifyValidSignature(purchase.getOriginalJson(), purchase.getSignature())) {
//            Log.i(TAG, "Got a purchase: " + purchase + "; but signature is bad. Skipping...");
//            return;
//        }
//
//        Log.d(TAG, "Got a verified purchase: " + purchase);
//
//        mPurchases.add(purchase);
//    }
//
//    private boolean verifyValidSignature(String signedData, String signature) {
//        // Some sanity checks to see if the developer (that's you!) really followed the
//        // instructions to run this sample (don't put these checks on your app!)
//        if (BASE_64_ENCODED_PUBLIC_KEY.contains("CONSTRUCT_YOUR")) {
//            throw new RuntimeException("Please update your app's public key at: "
//                    + "BASE_64_ENCODED_PUBLIC_KEY");
//        }
//
//        try {
//            return Security.verifyPurchase(BASE_64_ENCODED_PUBLIC_KEY, signedData, signature);
//        } catch (IOException e) {
//            Log.e(TAG, "Got an exception trying to validate a purchase: " + e);
//            return false;
//        }
//    }

}
