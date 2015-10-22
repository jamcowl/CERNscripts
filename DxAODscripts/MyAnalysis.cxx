#include "TestPackage/MyAnalysis.h"
#include "HGamAnalysisFramework/HgammaIncludes.h"
#include <cmath>
// this is needed to distribute the algorithm to the workers
ClassImp(MyAnalysis)



MyAnalysis::MyAnalysis(const char *name)
: HgammaAnalysis(name)
{
  // Here you put any code for the base initialization of variables,
  // e.g. initialize all pointers to 0.  Note that you should only put
  // the most basic initialization here, since this method will be
  // called on both the submission and the worker node.  Most of your
  // initialization code will go into histInitialize() and
  // initialize().
}



MyAnalysis::~MyAnalysis()
{
  // Here you delete any memory you allocated during your analysis.
}



EL::StatusCode MyAnalysis::createOutput()
{
  // Here you setup the histograms needed for you analysis. This method
  // gets called after the Handlers are initialized, so that the systematic
  // registry is already filled.

  histoStore()->createTH1F("m_yy"  , 60, 110, 140);
  histoStore()->createTH1F("pt_yy"  ,60, 0  ,  60);
  histoStore()->createTH1F("pt_y1" , 60, 0  , 100);
  histoStore()->createTH1F("pt_y2" , 60, 0  , 100);
  histoStore()->createTH1F("eta_y1", 25, -3 ,   3);
  histoStore()->createTH1F("eta_y2", 25, -3 ,   3);
  histoStore()->createTH1F("mu"    , 25,  0 ,  50);
  histoStore()->createTH1F("n_elec", 10,  0 ,  10);
  histoStore()->createTH1F("n_muon", 10,  0 ,  10);
  histoStore()->createTH1F("n_jets", 10,  0 ,  10);
  histoStore()->createTH1F("JVT_diffFrac", 20, -0.4,0.4);
  histoStore()->createTH1F("JVTold", 40, -1,1);
  histoStore()->createTH1F("JVTnew", 40, -1,1);

  return EL::StatusCode::SUCCESS;
}



EL::StatusCode MyAnalysis::execute()
{
  // Here you do everything that needs to be done on every single
  // events, e.g. read input variables, apply cuts, and fill
  // histograms and trees.  This is where most of your actual analysis
  // code will go.

  // Important to keep this, so that internal tools / event variables
  // are filled properly.
  HgammaAnalysis::execute();

  eventHandler()->pass();


  xAOD::PhotonContainer   photons   = photonHandler()   ->getCorrectedContainer();
  xAOD::ElectronContainer electrons = electronHandler() ->getCorrectedContainer();
  xAOD::MuonContainer     muons     = muonHandler()     ->getCorrectedContainer();
  xAOD::JetContainer      jets      = jetHandler()     ->getCorrectedContainer();

  if (photons.size() < 2) return EL::StatusCode::SUCCESS;

  if( passTriggerMatch(&photons) )   return EL::StatusCode::SUCCESS;
  if( passTriggerMatch(nullptr,&electrons,nullptr,nullptr) ) return EL::StatusCode::SUCCESS;
  if( passTriggerMatch(nullptr,nullptr   ,&muons ,nullptr) ) return EL::StatusCode::SUCCESS;
  if( passTriggerMatch(nullptr,nullptr   ,nullptr,&jets   ) ) return EL::StatusCode::SUCCESS;
  

  TLorentzVector y1 = photons[0]->p4();
  TLorentzVector y2 = photons[1]->p4();
  TLorentzVector h = y1 + y2;
//  std::cout << eventInfo()->eventNumber() << std::endl;
   
  eventHandler()->storeVariable("m_yy", float(h.M()));

  eventHandler()->writeVars(); 
  event()->fill();

  
  
  //  std::cout << y1.Pt() / HG::GeV << std::endl;
  histoStore()->fillTH1F("m_yy"  , h.M()   / HG::GeV);
  histoStore()->fillTH1F("pt_yy" , h.Pt()  / HG::GeV);
  histoStore()->fillTH1F("pt_y1" , y1.Pt() / HG::GeV);
  histoStore()->fillTH1F("pt_y2" , y2.Pt() / HG::GeV);
  histoStore()->fillTH1F("eta_y1", y1.Eta());
  histoStore()->fillTH1F("eta_y2", y2.Eta());
  histoStore()->fillTH1F("mu"    , eventInfo()-> averageInteractionsPerCrossing());
  histoStore()->fillTH1F("n_elec", electrons.size());
  histoStore()->fillTH1F("n_jets", jets.size());
  histoStore()->fillTH1F("n_muon", muons.size());


  return EL::StatusCode::SUCCESS;
}
